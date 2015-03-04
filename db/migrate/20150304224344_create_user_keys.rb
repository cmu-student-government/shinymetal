class CreateUserKeys < ActiveRecord::Migration
  def change
    create_table :user_keys do |t|
      t.string :status
      t.datetime :time_requested
      t.datetime :time_expired
      t.datetime :time_granted
      t.string :value
      t.text :application_text

      t.timestamps null: false
    end
  end
end
