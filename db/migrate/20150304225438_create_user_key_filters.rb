class CreateUserKeyFilters < ActiveRecord::Migration
  def change
    create_table :user_key_filters do |t|
      t.integer :user_key_id
      t.integer :filter_id

      t.timestamps null: false
    end
  end
end
