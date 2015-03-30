class CreateWhitelistFilters < ActiveRecord::Migration
  def change
    create_table :whitelist_filters do |t|
      t.integer :whitelist_id
      t.integer :filter_id

      t.timestamps null: false
    end
  end
end
