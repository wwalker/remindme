class CreateReminders < ActiveRecord::Migration[7.0]
  def change
    create_table :reminders do |t|
      t.datetime :deleted_at
      t.string :description
      t.string :detail
      t.integer :renotify_delay

      t.timestamps
    end
  end
end
