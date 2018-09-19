class UserMailer < ApplicationMailer

  def new_user(user, password, referrer, redirect_method)
    @user = user
    @password = password
    @referrer = referrer
    @redirect_method = redirect_method
    mail(to: @user.email, subject: "#{referrer.name} has sent you a message on Oslr")
  end


  def send_feedback(user, filename)
    attachments['OslrFeedbackCertificate.pdf'] = File.read(filename)
    @user = user
    mail(:to => user.email, :subject => "Oslr Feedback Certificate")
  end

  def new_password(user, password)
    @user = user
    @password = password
    mail(to: @user.email, subject: "Oslr: New Password Request")
  end

  def confirm_email(email_account)
    @email_account = email_account
    mail(to: @email_account.email, subject: "Oslr Confirmation Instructions")
  end

  def send_notification(user, message, link)
    @user = user
    @message = message
    @link = link
    mail(to: @user.email, subject: "Oslr: #{message}")
  end
end
