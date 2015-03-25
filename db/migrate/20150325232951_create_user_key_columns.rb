class CreateUserKeyColumns < ActiveRecord::Migration
  def change
    create_table :user_key_columns do |t|
      t.integer :user_key_id
      t.integer :column

      t.timestamps null: false
    end
  end
end
