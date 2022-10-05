class NotificationsController < ApplicationController
  def next_to_run
    if cron = Cron.next_to_run
      msg = cron.reminder.description
      notification = {'msg' => msg}
      notification['id'] = NotificationHistory.create!(cron_id: cron.id, started_at: Time.now).id
      render json: notification.to_json
    else
      render json: '{}'
    end
  end

  def snooze
    nh = NotificationHistory.find(params['id'])
    nh.snooze(params['time'])
    nh.ended_at = Time.now
  end

  def mark_as
    nh = NotificationHistory.find(params['id'])
    nh.mark_as(params['state'])
    nh.ended_at = Time.now
  end

  def next_runs
    render json: Cron.all.map{|x| {last_run: x.last_run, next_run: x.next_run, msg: x.reminder.description}}
  end

  def waiting
    if waiting = Cron.waiting
      render json: waiting.to_json
    else
      render json: '{}'
    end
  end
end
