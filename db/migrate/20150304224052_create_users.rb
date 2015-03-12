class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :andrew_id
      t.string :role, default: "requester"
      t.boolean :is_approver, default: false

      t.timestamps null: false
    end
  end
end
