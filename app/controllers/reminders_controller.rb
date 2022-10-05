class RemindersController < ApplicationController
  def next_to_run
    @oldest_reminder = Reminder.next_to_run
    respond_to do |format|
      format.json { render json: @oldest_reminder }
    end
  end

  def waiting
    @waiting = Reminder.waiting
    respond_to do |format|
      format.json { render json: @waiting }
    end
  end
end
