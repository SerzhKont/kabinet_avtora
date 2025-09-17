class DocumentsController < ApplicationController
  include Pagy::Backend
  include Pagy::Frontend

  before_action :authenticate_user!, only: [ :author_index, :sign_one, :sign_all ]
  before_action :ensure_manager, only: [ :edit, :update ]
  before_action :set_document, only: [ :show, :edit, :update, :destroy ]


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
    @pagy, @documents = pagy(@q.result(distinct: true).merge(scope).includes(:author, :uploaded_by))
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
    @document = Document.find(params[:id])
  end

  def update
    @document = Document.find(params[:id])
    if @document.update(document_params)
      @document.update(status: "linked") if @document.author_id.present? && @document.status == "unlinked"
      redirect_to @document, notice: "Документ успешно обновлен."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @document.destroy
    redirect_to documents_path, notice: "Документ удалён."
  end

  def unlinked
    @documents = Document.where(status: "unlinked").order(created_at: :desc)
  end

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:title, :author_id, :status, :file)
  end

  def ensure_manager
    redirect_to root_path, alert: "Доступ запрещен." unless current_user.manager? || current_user.admin?
  end
end
