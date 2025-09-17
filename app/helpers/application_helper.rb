module ApplicationHelper
  include Pagy::Frontend

  def pagy_nav(pagy)
    render "pagy/nav", pagy: pagy
  end
end
