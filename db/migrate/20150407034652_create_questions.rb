class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.text :message
      t.boolean :required
      t.boolean :active, default: true

      t.timestamps null: false
    end
  end
end
