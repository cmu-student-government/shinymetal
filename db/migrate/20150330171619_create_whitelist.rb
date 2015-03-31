class CreateWhitelist < ActiveRecord::Migration
  def change
    create_table :whitelists do |t|
      t.integer :user_key_id
      t.string :resource
      
      t.timestamps null: false
    end
  end
end
