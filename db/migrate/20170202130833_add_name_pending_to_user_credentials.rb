class AddNamePendingToUserCredentials < ActiveRecord::Migration
  def change
    add_column :user_credentials, :name_pending, :boolean
  end
end
