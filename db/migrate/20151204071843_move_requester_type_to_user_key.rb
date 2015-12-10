class MoveRequesterTypeToUserKey < ActiveRecord::Migration
  def change
    change_table :user_keys do |t|
      t.column :requester_type, :integer
      t.column :requester_additional_info, :text
    end

    change_table :express_apps do |t|
      t.remove :requester_type
      t.remove :requester_additional_info
    end
  end
end
