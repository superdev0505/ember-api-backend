class AlertsController < ApplicationController
  include JSONAPI::ActsAsResourceController

  def mark_read
    alerts = Alert.where(user_id: current_user.id, read_link: params[:url])
    alerts.all.each{|a| a.update_attribute(:unread, false)}
    head :ok
  end
end
