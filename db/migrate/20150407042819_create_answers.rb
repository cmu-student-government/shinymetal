class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :user_key_id
      t.integer :question_id
      t.text :message

      t.timestamps null: false
    end
  end
end
