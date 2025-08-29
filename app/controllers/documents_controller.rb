class DocumentsController < ApplicationController
  before_action :authenticate_user!
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
  end

  def update
    if @document.update(document_params)
      redirect_to @document, notice: "Документ обновлён."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @document.destroy
    redirect_to documents_path, notice: "Документ удалён."
  end

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:title, :description, :status, :signed_at, :file)
  end
end
