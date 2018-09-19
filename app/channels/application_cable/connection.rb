module ApplicationCable
  class Connection < ActionCable::Connection::Base

    identified_by :current_user

    def connect
      self.current_user = authenticate_user_from_token!
    end


    private

    def authenticate_user_from_token!
      user_email = request.params[:user_email].presence
      token = request.params[:token].presence
      user = false
      if user_email
        email_account = EmailAccount.includes(:user).where(:email => user_email).first
        user = email_account.user if email_account
      end
      if user && Devise.secure_compare(user.authentication_token, token)
        current_user = user
        return current_user
      else
        reject_unauthorized_connection
      end
    end

  end
end
