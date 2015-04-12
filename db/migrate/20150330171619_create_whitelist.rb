class CreateWhitelist < ActiveRecord::Migration
  def change
    create_table :whitelists do |t|
      t.integer :user_key_id
      
      t.timestamps null: false
    end
    
    add_index :whitelists, :user_key_id
  end
end
