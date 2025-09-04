class AuthorsController < ApplicationController
  before_action :ensure_manager, only: [ :new, :create, :edit, :update ]

  def new
    @author = Author.new
  end

  def create
    @author = Author.new(author_params)
    if @author.save
      redirect_to @author, notice: "Автор успешно создан."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def author_params
    params.require(:author).permit(:name, :email_address, :code)
  end

  def ensure_manager
    redirect_to root_path, alert: "Доступ запрещен." unless current_user.manager? || current_user.admin?
  end
end
