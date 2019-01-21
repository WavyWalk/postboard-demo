class AddAvatarColumnsToUsers < ActiveRecord::Migration
  def up
    add_attachment :users, :avatar
    add_column :users, :s_avatar, :text
  end

  def down
    remove_attachment :users, :avatar
    remove_column :users, :s_avatar, :text
  end
end
