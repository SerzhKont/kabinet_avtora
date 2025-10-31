class DocumentGroupsController < ApplicationController
  allow_unauthenticated_access only: [ :show, :show_document, :sign, :signing ]
  layout "public"

  def show
    @group = DocumentGroup.find_valid(params[:token])

    if @group
      @documents = @group.documents.order(created_at: :desc)
      @author = @group.author
    else
      render "link_invalid", status: :not_found
    end
  end

  def show_document
    @group = DocumentGroup.find_valid(params[:token])

    if @group
      @document = @group.documents.find_by(id: params[:id])
      if @document
        @author = @group.author
      else
        render "link_invalid", status: :not_found
      end
    else
      render "link_invalid", status: :not_found
    end
  end

  def sign
    @group = DocumentGroup.find_valid(params[:token])

    if @group
      @documents = @group.documents.order(created_at: :desc)
      @author = @group.author
    else
      render "link_invalid", status: :not_found
    end
  end

  def signing
    @group = DocumentGroup.find_valid(params[:token])

    if @group
      # Here we would integrate with Diia service for actual signing
      # For now, we'll mark documents as signed
      @group.documents.update_all(signed_at: Time.current)
      @group.update(signed_at: Time.current)

      redirect_to document_group_path(@group.token), notice: "Документи успішно підписані!"
    else
      render "link_invalid", status: :not_found
    end
  end
end
