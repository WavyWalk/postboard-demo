class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :user_roles do |t|
      t.text :name
    end
    add_index :user_roles, :name
  end
end
