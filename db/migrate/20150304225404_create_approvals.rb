class CreateApprovals < ActiveRecord::Migration
  def change
    create_table :approvals do |t|
      t.integer :user_id
      t.integer :user_key_id

      t.timestamps null: false
    end
  end
end
