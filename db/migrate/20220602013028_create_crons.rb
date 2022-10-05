class CreateCrons < ActiveRecord::Migration[7.0]
  def change
    create_table :crons do |t|
      t.string :reminder_id
      t.string :entry
      t.datetime :last_run, default: '2000-01-01T00:00:00.000 UTC'
      t.datetime :next_run, default: '2000-01-01T00:00:00.000 UTC'
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
