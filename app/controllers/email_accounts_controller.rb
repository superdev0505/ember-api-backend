class EmailAccountsController < ApplicationController
  include JSONAPI::ActsAsResourceController

  def resend_confirmation
    @email_account = EmailAccount.find(params[:id])
    @email_account.send_confirmation_email
    render nothing: true
  end

  def submit_confirmation_code
    @email_account = EmailAccount.find(params[:id])
    code = params[:confirmation_code]
    if @email_account.confirmation_code == code
      @email_account.confirm!
      render json: @email_account, status: 200
    else
      render plain: "That code seems to be incorrect, please check your email and try again", status: 401
    end
  end

end
