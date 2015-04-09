class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :name
      t.string :url
      t.text :message

      t.timestamps null: false
    end
  end
end
