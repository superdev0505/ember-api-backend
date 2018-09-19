class SessionsController < Devise::SessionsController

  skip_before_action :authenticate_user!

  def create
    respond_to do |format|
      format.html { super }
      format.json do

        params[:user] ||= {}

        email_account = EmailAccount.where(:email => params[:user][:user_email]).includes(:user).first
        self.resource = email_account.nil? ? nil : email_account.user
        # self.resource = User.where(:email => params[:user][:user_email]).first
        if self.resource.nil? || !self.resource.valid_password?(params[:user][:password])
          render json: {errors: "Email or password is invalid."}, status: 401
          return
        end

        sign_in(resource_name, resource)
        data = {
          token: self.resource.authentication_token,
          user_email: self.resource.email,
          user_id: self.resource.id,
          user_confirmed: self.resource.confirmed?,
          user_terms: self.resource.terms
        }
        render json: data, status: 201
      end
    end
  end
end
