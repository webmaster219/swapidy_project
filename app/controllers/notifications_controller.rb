class NotificationsController < ApplicationController
  
  before_filter :require_login
  
  def index
  end

  def refresh
    respond_to do |format|
      format.js {
        @notifications_menu = render_to_string(:partial => "/layouts/notifications_menu")
      }
    end
  end
  
  def hide
    if params[:id] == "all"
      @notification_id = "all"
      current_user.notifications.unread.each {|notification| notification.update_attribute(:has_read, true) }
    else
      notification = current_user.notifications.find params[:id]
      notification.update_attribute(:has_read, true)
      @notification_id = notification.id.to_s
    end
    respond_to do |format|
      format.js {
        @notifications_menu = render_to_string(:partial => "/layouts/notifications_menu")
      }
    end
  end

end