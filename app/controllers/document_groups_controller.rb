class DocumentGroupsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :show ]
  layout "public"

  def show
    @group = DocumentGroup.find_valid(params[:token])

    if @group
      @documents = @group.documents.order(created_at: :desc)
      @author = @group.author
      # ... и рендерим app/views/document_groups/show.html.erb
    else
      render "link_invalid", status: :not_found
    end
  end
end
