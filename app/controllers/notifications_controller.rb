class NotificationsController < ApplicationController
  def next_to_run
    cron = Cron.next_to_run
    msg = cron.reminder.description
    notification = {'msg' => msg}
    notification['id'] = NotificationHistory.create!(cron_id: cron.id).id

    render json: notification.to_json
  end

  def snooze
    pp params
    NotificationHistory.find(params['id']).snooze(params['time'])
  end

  def mark_as
    NotificationHistory.find(params['id']).mark_as(params['state'])
  end

  def waiting
    @waiting = Cron.waiting
      render json: @waiting.to_json
  end
end
