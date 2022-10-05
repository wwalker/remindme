class NotificationHistory < ApplicationRecord
  belongs_to :cron

  def mark_as(state)
    now = Time.now

    puts "state:<#{state}>"
    case state
    when 'Done', 'Already Done', 'Skip'
      self.ended_at = now
      self.result = state
      self.cron.update_next_run!
      self.save!
    else
      die("Bad input - state:<#{state}>")
    end
  end

  def snooze(period)
    now = Time.now
    self.result = period
    self.ended_at = now

    period.gsub!(/\s+/,'')
    case period
    when /^(\d+)h$/
      period=3600*$1.to_i
    when /^(\d+)m?$/
      period=60*$1.to_i
    when /^(\d+)s$/
      period=$1.to_i
    else
      die("Bad input - period:<#{period}>")
    end
    self.cron.next_run = now + period
    self.cron.save!
    self.save!
  end
end
