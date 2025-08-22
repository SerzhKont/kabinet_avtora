class DocumentsController < ApplicationController
  before_action :authenticate_user!, except: [ :show ]
  before_action :set_document, only: [ :show ]
  before_action :authorize_access, only: [ :show ]

  def index
    if current_user&.admin?
      @documents = Document.all
    elsif current_user&.manager?
      @documents = Document.where(uploaded_by_id: current_user.id)
    elsif current_user&.client?
      @documents = Document.where(client_id: current_user.id)
    else
      @documents = Document.none
    end
  end

  def show
  end

  def new
    @document = Document.new
  end

  def create
    @document = Document.new(document_params)
    @document.uploaded_by = current_user
    @document.client = User.find_by(client_code: params[:document][:client_code])

    if @document.save
      redirect_to @document, notice: "Document created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def authorize_access
    unless current_user&.admin? || @document.client_id == current_user&.id || @document.uploaded_by_id == current_user&.id
      redirect_to root_path, alert: "Access denied."
    end
  end

  def document_params
    params.expect(document: [ :title, :file, :client_code ])
  end
end
