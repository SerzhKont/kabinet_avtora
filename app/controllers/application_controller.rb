class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Method
  before_action { Pagy::I18n.locale = "uk" }
  before_action :set_paper_trail_whodunnit

  skip_before_action :require_authentication, only: [ :dismiss_notification ]
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user, :authenticated?

  def current_user
    @current_user ||= find_session_by_cookie&.user
  end

  def authenticated?
    !current_user.nil?
  end

  def authenticate_user!
    unless authenticated?
      redirect_to new_session_path, alert: "Please log in to access this page."
    end
  end

  def after_authentication_url
    root_path
  end

  def dismiss_notification
    flash.delete(params[:type].to_sym)
    respond_to do |format|
      format.html { render partial: "layouts/notifications", locals: { flash: flash } }
    end
  end
end
