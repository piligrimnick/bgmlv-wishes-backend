class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Doorkeeper code
  before_action :doorkeeper_authorize! # Requires access token for all actions

  respond_to :json

  rescue_from ArgumentError do |e|
    render json: { 'ErrorType' => 'Validation Error', 'message' => e.message },
           code: :bad_request
  end

  protected

  # Devise methods
  # Authentication key(:username) and password field will be added automatically by devise.
  def configure_permitted_parameters
    added_attrs = [:email]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  private

  def current_resource_owner
    return @current_resource_owner if defined?(@current_resource_owner)
    
    @current_resource_owner = doorkeeper_token ? User.find(doorkeeper_token.resource_owner_id) : nil
  end

  alias current_user current_resource_owner
end
