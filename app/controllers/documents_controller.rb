class DocumentsController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_user!, only: [ :author_index, :sign_one, :sign_all ]
  before_action :ensure_manager, only: [ :edit, :update, :destroy, :bulk_action ]
  before_action :set_document, only: [ :show, :edit, :update, :confirm_destroy, :confirm_send_for_signature ]

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
    render "edit"
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
    render partial: "confirm_destroy_modal"
  end

  def confirm_bulk_destroy
    render partial: "confirm_bulk_destroy_modal"
  end

  def confirm_send_for_signature
    render partial: "confirm_send_for_signature_modal"
  end

  def confirm_bulk_send_for_signature
    render partial: "confirm_bulk_send_for_signature_modal"
  end

  def destroy
    document = Document.find(params[:id])
    document.destroy

    @q = Document.ransack(params[:q])
    scope = params[:status].present? ? Document.where(status: params[:status]) : Document.all
    items_per_page = params[:items]&.to_i || 25
    items_per_page = [ 25, 50, 100, 200, 500 ].include?(items_per_page) ? items_per_page : 25
    @pagy, @documents = pagy(@q.result.merge(scope).includes(:author, :uploaded_by), limit: items_per_page)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "documents_table",
          partial: "documents/table",
          locals: { documents: @documents, pagy: @pagy, q: @q }
        )
      end
      format.html { redirect_to documents_path, notice: "Документ успішно видалено!" }
    end
  end

  def bulk_action
    document_ids = params[:document_ids] || []
    action = params[:bulk_action]

    if document_ids.empty?
      redirect_to documents_path, alert: "Не выбрано ни одного документа"
      return
    end

    case action
    when "delete"
        bulk_delete(document_ids)
    when "email"
        bulk_email(document_ids)
    else
        redirect_to documents_path, alert: "Выберите действие"
    end

    # Повторно загружаем документы для обновления таблицы
    @q = Document.ransack(params[:q])
    scope = params[:status].present? ? Document.where(status: params[:status]) : Document.all
    items_per_page = params[:items]&.to_i || 25
    items_per_page = [ 25, 50, 100, 200, 500 ].include?(items_per_page) ? items_per_page : 25
    @pagy, @documents = pagy(@q.result.merge(scope).includes(:author, :uploaded_by), limit: items_per_page)

    # Рендерим index для обновления turbo-frame
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

  def unlinked
    @q = Document.where(status: "unlinked").ransack(params[:q])
    @documents = @q.result.order(created_at: :desc)
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

  def bulk_delete(document_ids)
    count = Document.where(id: document_ids).destroy_all.count
    flash.now[:notice] = "Удалено документов: #{count}"
  end

  def bulk_email(document_ids)
    documents = Document.where(id: document_ids)

    # Отправка через фоновую задачу (рекомендуется)
    # DocumentMailerJob.perform_later(documents.pluck(:id))

    # Или синхронная отправка (для простоты)
    documents.each do |document|
      DocumentMailer.send_document(document).deliver_later
    end

    flash.now[:notice] = "Отправка #{documents.count} документов запланирована"
  end
end
