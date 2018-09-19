class ApplicationMailer < ActionMailer::Base
  default from: Rails.env == "production" ? "info@oslr.co.uk" : "dev@oslr.co.uk"
  layout 'mailer'
end
