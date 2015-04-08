class CreateUserKeyOrganizations < ActiveRecord::Migration
  def change
    create_table :user_key_organizations do |t|
      t.integer :user_key_id
      t.integer :organization_id

      t.timestamps null: false
    end
    
    add_index :user_key_organizations, [ :user_key_id, :organization_id ], name: "user_org_association_index"
  end
end
