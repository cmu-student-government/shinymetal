class CreateColumns < ActiveRecord::Migration
  def change
    create_table :columns do |t|
      t.string :resource
      t.string :column_name

      t.timestamps null: false
    end
  end
end
