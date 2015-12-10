class AddUserKeyToExpressApp < ActiveRecord::Migration
  def change
    add_reference :express_apps, :user_key, index: true, foreign_key: true
  end
end
