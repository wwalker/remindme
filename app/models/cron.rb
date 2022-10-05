class Cron < ApplicationRecord
  belongs_to :reminder
  before_create :git_er_done
  has_many :notification_histories

  def self.next_to_run
    # Cron.all.map{|c| c.next_run }.sort.first
    all.sort{ |a, b|  a.next_run <=> b.next_run }.first
  end

  def self.waiting
    now = Time.now
    # Cron.all.select{|x| x.next_run < now}.sort{ |a, b|  a.next_run <=> b.next_run }
    all.select{|x| x.next_run < now}
  end

  def update_next_run!
    update_next_run
    save!
  end

  # FIX ME - race condition if the "next run time" was in the last few seconds...
  # maybe pass in the time from the NotificationHistory?
  def update_next_run
    self.last_run = Time.now
    self.next_run = next_run_time(self.last_run)
  end

  def next_run_time(now=Time.now)
    cp = CronParser.new(entry)
    cp.next(now)
  end

  def git_er_done
    cp = CronParser.new(entry)
    last_cron_run_time = cp.last(Time.now)

    self.next_run = (last_cron_run_time > self.last_run) ? cp.next(Time.now) : last_cron_run_time
  end
end
