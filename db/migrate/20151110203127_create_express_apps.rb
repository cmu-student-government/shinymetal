class CreateExpressApps < ActiveRecord::Migration
  def change
    create_table :express_apps do |t|
      t.integer :requester_type
      t.text :reasoning
      t.text :requester_additional_info
      t.boolean :tos_agree

      t.timestamps null: false
    end
  end
end
