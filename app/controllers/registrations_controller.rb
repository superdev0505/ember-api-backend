class RegistrationsController < Devise::RegistrationsController

  skip_before_action :authenticate_user!

end
