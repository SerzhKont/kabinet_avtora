class DocumentsController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_user!, only: [ :author_index, :sign_one, :sign_all ]
  before_action :ensure_manager, only: [ :edit, :update, :destroy, :bulk_delete ]
  before_action :set_document, only: [ :show, :edit, :update, :destroy, :confirm_destroy ]

  def author_index
    @author = Author.find_by(code: params[:author_code])
    if @author
      @documents = @author.documents.where(status: [ "pending", "linked" ])
    else
      redirect_to root_path, alert: "Автор із кодом #{params[:author_code]} не знайдений."
    end
  end

  def sign_one
    @document = Document.find(params[:id])
    @author = Author.find_by(code: params[:author_code])
    unless @author && @document.author == @author
      redirect_to root_path, alert: "Недійсний документ або код автора."
      return
    end
    # Заглушка для Дія.Підпис (добавим позже)
    redirect_to author_documents_path(author_code: @author.code), notice: "Підпис одного документа (заглушка)."
  end

  def sign_all
    @author = Author.find_by(code: params[:author_code])
    unless @author
      redirect_to root_path, alert: "Автор із кодом #{params[:author_code]} не знайдений."
      return
    end
    @documents = @author.documents.where(status: [ "pending", "linked" ]).limit(7)  # Max 7 для Дія
    # Заглушка для Дія.Підпис
    redirect_to author_documents_path(author_code: @author.code), notice: "Підпис всіх документів (заглушка)."
  end

  def index
    @q = Document.ransack(params[:q])
    scope = params[:status].present? ? Document.where(status: params[:status]) : Document.all
    items_per_page = params[:items]&.to_i || 25
    items_per_page = [ 25, 50, 100, 200, 500 ].include?(items_per_page) ? items_per_page : 25
    @pagy, @documents = pagy(@q.result.merge(scope).includes(:author, :uploaded_by), limit: items_per_page)
  end

  def show
  end

  def new
    @document = Document.new
  end

  def create
    if params[:document][:files].present?
      params[:document][:files].each do |uploaded_file|
        Document.create(
          file: uploaded_file,
          uploaded_by: current_user
        )
      end
      redirect_to documents_path, notice: "Документи завантажені."
    else
      redirect_to new_document_path, alert: "Оберіть хоча б один файл."
    end
  end

  def edit
    render template: "documents/edit"
  end

  def update
    @document = Document.find(params[:id])
    if @document.update(document_params)
      new_status = @document.author_id.present? ? "linked" : "unlinked"
      @document.update(status: new_status)
      redirect_to documents_path,
                  notice: "Документ '#{@document.title}' успішно оновлено. " +
                          (@document.author ? "Прив'язано до автора: #{@document.author.name}" : "Автора видалено")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def confirm_destroy
    render template: "documents/confirm_destroy"
  end

  def destroy
    @document.destroy

    @q = Document.ransack(params[:q])
    scope = params[:status].present? ? Document.where(status: params[:status]) : Document.all
    items_per_page = params[:items]&.to_i || 25
    items_per_page = [ 25, 50, 100, 200, 500 ].include?(items_per_page) ? items_per_page : 25
    @pagy, @documents = pagy(@q.result.merge(scope).includes(:author, :uploaded_by), limit: items_per_page)

    respond_to do |format|
      format.turbo_stream do
        # Заменяем всю таблицу новым partial
        render turbo_stream: turbo_stream.replace(
          "documents_table",
          partial: "documents/table",
          locals: { documents: @documents, pagy: @pagy }
        )
      end
      format.html { redirect_to documents_path, notice: "Документ успішно видалено!" }
    end
  end

  def bulk_delete
    if params[:document_ids].present?
      Document.where(id: params[:document_ids]).destroy_all
      respond_to do |format|
        format.html { redirect_to documents_path, notice: "Вибрані документи видалено." }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("documents_table", partial: "documents/table", locals: { documents: Document.all, pagy: nil }),
            turbo_stream.update("notifications", partial: "shared/notice", locals: { notice: "Вибрані документи видалено." }),
            turbo_stream.append("body", "<script>document.querySelector('[data-controller=\"checkbox\"]').checkboxController.resetCheckboxes()</script>")
          ]
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to documents_path, alert: "Оберіть хоча б один документ для видалення." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("notifications", partial: "shared/alert", locals: { alert: "Оберіть хоча б один документ для видалення." })
        end
      end
    end
  end

  def unlinked
    @documents = Document.where(status: "unlinked").order(created_at: :desc)
  end

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:author_id, :title, :status)
  end

  def ensure_manager
    unless current_user && (current_user.manager? || current_user.admin?)
      redirect_to root_path, alert: "Доступ запрещен."
      false
    end
  end
end
