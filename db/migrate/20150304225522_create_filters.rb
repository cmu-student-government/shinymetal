class CreateFilters < ActiveRecord::Migration
  def change
    create_table :filters do |t|
      t.string :resource
      t.string :filter_name
      t.string :filter_value

      t.timestamps null: false
    end
  end
end
