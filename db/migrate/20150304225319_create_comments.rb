class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :message
      t.boolean :is_private
      t.datetime :time_posted

      t.timestamps null: false
    end
  end
end
