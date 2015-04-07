class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :andrew_id
      t.string :role, default: "requester"
      t.boolean :active, default: true

      t.timestamps null: false
    end
    
    add_index :users, :andrew_id
    
  end
end
