class CreateAppointments < ActiveRecord::Migration[7.0]
  def change
    create_table :appointments do |t|
      t.string :reminder_id
      t.string :result
      t.datetime :started_at, default: '2000-01-01T00:00:00.000 UTC'
      t.datetime :ended_at, default: '2000-01-01T00:00:00.000 UTC'
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
