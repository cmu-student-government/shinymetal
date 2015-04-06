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
      t.text :proposal_text_one
      t.text :proposal_text_two
      t.text :proposal_text_three
      t.text :proposal_text_four
      t.text :proposal_text_five
      t.text :proposal_text_six
      t.text :proposal_text_seven
      t.text :proposal_text_eight
      t.boolean :agree, default: false

      t.timestamps null: false
    end
    
    add_index :user_keys, [:time_submitted,
                           :time_filtered, :time_confirmed, :time_expired],
                           name: "user_key_ordering_index"
    add_index :user_keys, :user_id, name: "user_key_fetching_index"
  end
end
