class CreateUserKeys < ActiveRecord::Migration
  def change
    create_table :user_keys do |t|
      t.integer :user_id
      t.string :status, default: "awaiting_submission"
      t.datetime :time_submitted
      t.datetime :time_filtered
      t.datetime :time_confirmed
      t.date :time_expired
      t.boolean :active, default: true
      t.string :name

      t.timestamps null: false
    end
    
    add_index :user_keys, [:time_submitted,
                           :time_filtered, :time_confirmed, :time_expired],
                           name: "user_key_ordering_index"
    add_index :user_keys, :user_id, name: "user_key_fetching_index"
  end
end
