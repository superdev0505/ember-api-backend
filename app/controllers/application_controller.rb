class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception

  before_action :authenticate_user_from_token! # Finds current user from a token
  before_action :authenticate_user! # Returns 401 if not logged in - overwritten in some controllers

  # before_action :configure_permitted_parameters, if: :devise_controller?

  respond_to :json

  # Read the custom headers and make available to all controllers
  def read_headers
    @app_environment = request.headers["x-vendor-appEnvironment"]
    @app_version = request.headers["x-vendor-appVersion"]
  end
  before_action :read_headers

  private

  def authenticate_user_from_token!
    authenticate_with_http_token do |token, options|
      user_email = options[:user_email].presence
      user = false
      if user_email && user_email != 'undefined'
        email_account = EmailAccount.includes(:user).where(:email => user_email).first
        user = email_account.user if email_account
      end
      return false unless user
      # user       = user_email && User.find_by_email(user_email)

      if(Rails.env != 'production') # For testing, log them in based on email only, ignore the token
        sign_in user, store: false
      else
        if user && Devise.secure_compare(user.authentication_token, token)
          sign_in user, store: false
        end
      end
    end
  end


  # Create a notification on multiple actions - automatically save the action called
  # If users are passed in, their notifications are marked as 'unread' and they are sent push notifications
  def track_activity(object, text, users=nil, action=params[:action])
    object_activity = ObjectActivity.create!(
      target: object,
      action: action,
      body: text
    )
    object_activity.notify!(users)
  end

  protected

  # def configure_permitted_parameters
  #   devise_parameter_sanitizer.for(:sign_up) << :name
  # end


  # Overwrite devise authentication to prevent HTML redirection
  def authenticate_user!
    unless current_user
      render :json => {'error' => 'authentication error'}, :status => 401
    end
  end


  def admin_only!
    unless current_user && current_user.admin
      raise "Only admin users can view behaviour data (user #{current_user.nil? ? 'nil' : current_user.id} logged in)"
    end
  end
end
