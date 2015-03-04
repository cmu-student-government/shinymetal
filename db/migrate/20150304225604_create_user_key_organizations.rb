class CreateUserKeyOrganizations < ActiveRecord::Migration
  def change
    create_table :user_key_organizations do |t|
      t.integer :user_key_id
      t.integer :organization_id

      t.timestamps null: false
    end
  end
end
