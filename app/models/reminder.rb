class Reminder < ApplicationRecord
  has_many :crons
  has_many :appointments

  def self.next_to_run
    Reminder.find(Cron.next_to_run.reminder_id)
  end

  def self.waiting
    Cron.waiting.map{|c| Reminder.find(c.reminder_id)}
  end
end
