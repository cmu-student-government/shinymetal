class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :message
      t.boolean :public, default: false
      t.integer :user_id
      t.integer :user_key_id

      t.timestamps null: false
    end
    
    add_index :comments, :user_key_id
  end
end
