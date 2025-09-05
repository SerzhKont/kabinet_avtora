class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_manager, only: [ :edit, :update ]
  before_action :set_document, only: [ :show, :edit, :update, :destroy ]

  def index
    if params[:status].present?
      @documents = Document.where(status: params[:status]).order(created_at: :desc)
    else
      @documents = Document.all.order(created_at: :desc)
    end
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
    params.require(:document).permit(:title, :author_id, :status)
  end

  def ensure_manager
    redirect_to root_path, alert: "Доступ запрещен." unless current_user.manager? || current_user.admin?
  end
end
