class CreateFilters < ActiveRecord::Migration
  def change
    create_table :filters do |t|
      t.string :resource
      t.string :filter_name
      t.string :filter_value

      t.timestamps null: false
    end
    
    add_index :filters, [:resource, :filter_name, :filter_value ], name: "resource_name_value_index"
  end
end
