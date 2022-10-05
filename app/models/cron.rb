class Cron < ApplicationRecord
  belongs_to :reminder
  before_create :set_run_times
  has_many :notification_histories

  def self.next_to_run
    # Cron.all.map{|c| c.next_run }.sort.first
    # all.sort{ |a, b|  a.next_run <=> b.next_run }.first
    waiting.first
  end

  def self.waiting
    now = Time.now
    # Cron.all.select{|x| x.next_run < now}.sort{ |a, b|  a.next_run <=> b.next_run }
    all.select{|x| x.next_run < now}.sort{ |a, b|  a.next_run <=> b.next_run }
  end

  def update_next_run!
    update_next_run
    save!
  end

  # FIX ME - race condition if the "next run time" was in the last few seconds...
  # maybe pass in the time from the NotificationHistory?
  def update_next_run
    now = Time.now
    self.last_run = now
    self.next_run = next_run_time
    save
  end

  def next_run_time(now=Time.now)
    cp = CronParser.new(entry)
    nrt = cp.next(now)
  end

  def set_run_times
    cp = CronParser.new(entry)
    last_cron_run_time = cp.last(Time.now)

    self.next_run = ((last_cron_run_time > self.last_run) ? cp.next(Time.now) : last_cron_run_time) - 24.hour
  end
end
