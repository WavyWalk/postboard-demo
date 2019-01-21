class CreateUserRoleLinks < ActiveRecord::Migration
  def change
    create_table :user_role_links do |t|
      t.references :user, index: true, foreign_key: true
      t.references :user_role, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
