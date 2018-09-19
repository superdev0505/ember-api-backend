class UsersController < ApplicationController
  include JSONAPI::ActsAsResourceController

  skip_before_action :authenticate_user!, only: [:forgot_password]

  # Context passed to jsonapi resource objects
  def context
    {
      current_user: current_user,
      app_environment: request.headers["x-vendor-appEnvironment"],
      app_version: request.headers["x-vendor-appVersion"]
    }
  end

  def resend_confirmation_email
    current_user.send_confirmation_instructions
    render json: current_user
  end


  # Utility method for auto-confirming users in test envirnoment
  # Disabled in production
  def test_confirm
    raise "Auto-confirm method not available in production" if Rails.env == 'production'
    puts "Auto-confirming user #{current_user.email}"
    current_user.confirm
    current_user.email_accounts.each{|a| a.confirm!}
    render text: "Confirmed user #{current_user.id}"
  end

  # Change a password
  # Needs the old password
  def change_password
    @user = User.find(params[:id])
    raise("Trying to change someone else's password!") unless @user == current_user
    unless @user.valid_password?(params[:old_password])
      render text: "Incorrect old password."
      return
    end
    unless params[:new_password] == params[:new_password_confirmation]
      render text: "Password and confirmation do not match."
      return
    end
    if @user.update_attributes(:password => params[:new_password], :password_confirmation => params[:new_password_confirmation])
      render text: "Password changed successfully."
    else
      render text: "Sorry, there was a problem updating your password."
    end
  end

  # A user submits an email
  # They are sent a reset password code (4 digit number)
  # They can then enter the code and a new password to reset it
  def forgot_password
    @user = User.joins(:email_accounts).where(email_accounts: {email: params[:email]}).first
    if @user.nil?
      render text: "We couldn't find an account with that email address. Please check the spelling and try again.", status: 404
      return
    end

    # TODO: successful confirmation code
  end



  # Upload an avatar, process with carrierwave
  def upload_avatar
    current_user.avatar = params[:file]
    current_user.save!
    render json: current_user
  end
  def delete_avatar
    current_user.remove_avatar!
    current_user.save
    current_user.generate_avatar
    render json: current_user
  end

end
