class CreateUserKeys < ActiveRecord::Migration
  def change
    create_table :user_keys do |t|
      t.integer :user_id
      t.integer :status
      t.string :status
      t.datetime :time_submitted
      t.datetime :time_filtered
      t.datetime :time_approved
      t.datetime :time_expired
      t.string :value
      t.text :application_text

      t.timestamps null: false
    end
  end
end
