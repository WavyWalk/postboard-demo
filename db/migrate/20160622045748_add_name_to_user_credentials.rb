class AddNameToUserCredentials < ActiveRecord::Migration
  def change
    add_column :user_credentials, :name, :text
  end
end
