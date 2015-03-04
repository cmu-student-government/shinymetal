class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :andrew_id
      t.string :role
      t.boolean :is_approver

      t.timestamps null: false
    end
  end
end
