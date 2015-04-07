class CreateUserKeyColumns < ActiveRecord::Migration
  def change
    create_table :user_key_columns do |t|
      t.integer :user_key_id
      t.integer :column_id

      t.timestamps null: false
    end
    
    add_index :user_key_columns, [ :user_key_id, :column_id ]
  end
end
