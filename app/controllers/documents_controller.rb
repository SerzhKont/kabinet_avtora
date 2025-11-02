class DocumentsController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_user!, only: [ :author_index ]
  before_action :ensure_manager, only: [ :edit, :update, :destroy, :bulk_action, :send_single ]
  before_action :set_document, only: [ :show, :edit, :update, :confirm_destroy, :confirm_send_for_signature ]

  def author_index
    @author = Author.find_by(code: params[:author_code])
    if @author
      @documents = @author.documents.where(status: [ "pending", "linked" ])
    else
      redirect_to root_path, alert: "Автор із кодом #{params[:author_code]} не знайдений."
    end
  end

  def index
    @q = Document.ransack(params[:q])
    scope = case params[:author_filter]
    when "with_author"
              Document.where.not(author_id: nil)
    when "without_author"
              Document.where(author_id: nil)
    else
              Document.all
    end
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
    new_status = document_params[:author_id].present? ? "linked" : "unlinked"

    if @document.update(document_params.merge(status: new_status))
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
    scope = case params[:author_filter]
    when "with_author"
              Document.where.not(author_id: nil)
    when "without_author"
              Document.where(author_id: nil)
    else
              Document.all
    end
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

  def send_single
    @document = Document.find(params[:id])

    if @document.status == "pending"
      redirect_to documents_path, alert: "Документ уже находится в процессе подписания (статус: pending)"
      return
    elsif @document.status == "linked" && @document.author_id.present?
      DocumentGroupMailerService.call([ @document.id ])
      @document.update(status: "pending", sent_for_signature_at: Time.current)
    else
      redirect_to documents_path, alert: "Документ не может быть отправлен на подпись"
      return
    end

    @q = Document.ransack(params[:q])
    scope = case params[:author_filter]
    when "with_author"
              Document.where.not(author_id: nil)
    when "without_author"
              Document.where(author_id: nil)
    else
              Document.all
    end
    items_per_page = params[:items]&.to_i || 25
    items_per_page = [ 25, 50, 100, 200, 500 ].include?(items_per_page) ? items_per_page : 25
    @pagy, @documents = pagy(@q.result.merge(scope).includes(:author, :uploaded_by), limit: items_per_page)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "documents_table",
          partial: "documents/table",
          locals: { documents: @documents, pagy: @pagy }
        )
      end
      format.html { redirect_to documents_path, notice: "Документ успішно відправлено на підпис!" }
    end

  rescue ActiveRecord::RecordNotFound
    redirect_to documents_path, alert: "Документ не найден."
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
        @result = bulk_delete(document_ids)
    when "send"
        @result = bulk_send(document_ids)
    else
        redirect_to documents_path, alert: "Выберите действие"
        return
    end

    # Повторно загружаем документы для обновления таблицы
    @q = Document.ransack(params[:q])
    scope = case params[:author_filter]
    when "with_author"
              Document.where.not(author_id: nil)
    when "without_author"
              Document.where(author_id: nil)
    else
              Document.all
    end
    items_per_page = params[:items]&.to_i || 25
    items_per_page = [ 25, 50, 100, 200, 500 ].include?(items_per_page) ? items_per_page : 25
    @pagy, @documents = pagy(@q.result.merge(scope).includes(:author, :uploaded_by), limit: items_per_page)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("bulk_action_modal"),
          turbo_stream.replace(
            "documents_table",
            partial: "documents/table",
            locals: { documents: @documents, pagy: @pagy }
          ),
          turbo_stream.replace("notifications", partial: "layouts/notifications", locals: {
            flash: @result[:success] ? { notice: @result[:message] } : { alert: @result[:message] }
          })
        ]
      end
      format.html { redirect_to documents_path, notice: @result[:success] ? @result[:message] : nil, alert: @result[:success] ? nil : @result[:message] }
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
    { success: true, message: "Удалено документов: #{count}" }
  end

  def bulk_send(document_ids)
    document_ids = params[:document_ids]

    if document_ids.blank?
      return { success: false, message: "Вы не выбрали ни одного документа." }
    end

    # Проверяем, есть ли документы со статусом pending
    pending_documents = Document.where(id: document_ids, status: "pending")
    if pending_documents.any?
      return { success: false, message: "Некоторые документы уже находятся в процессе подписания" }
    end

    DocumentGroupMailerService.call(document_ids)
    { success: true, message: "Документы отправлены на подпись" }
  end
end
