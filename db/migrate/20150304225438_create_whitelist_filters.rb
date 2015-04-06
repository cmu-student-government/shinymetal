class CreateWhitelistFilters < ActiveRecord::Migration
  def change
    create_table :whitelist_filters do |t|
      t.integer :whitelist_id
      t.integer :filter_id

      t.timestamps null: false
    end
    
    add_index :whitelist_filters, [ :whitelist_id , :filter_id ]
  end
end
