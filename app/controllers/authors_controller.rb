class AuthorsController < ApplicationController
  def index
    @authors = Author.all
  end

  def new
    @author = Author.new
  end

  def show
  end

  def create
    @author = Author.new(author_params)
    if @author.save
      redirect_to @author, notice: "Автор успешно создан."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @author = Author.find(params[:id])
    if @author.destroy
      flash[:notice] = "Автор успешно удален."
    else
      flash[:alert] = "Ошибка при удалении автора."
    end
    redirect_to authors_path
  end

  def author_index
    @author = Author.find_by(access_token: params[:access_token])
    if @author && @author.access_token_expires_at > Time.current
      @documents = @author.documents.where(status: [ "pending", "linked" ])
    else
      redirect_to root_path, alert: "Посилання недійсне або прострочене."
    end
end
  private

  def author_params
    params.require(:author).permit(:name, :email_address, :code)
  end
end
