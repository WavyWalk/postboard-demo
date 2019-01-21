class CreateUserSubscriptions < ActiveRecord::Migration
  def change
    create_table :user_subscriptions do |t|
      t.references :user, index: true, foreign_key: true, index: true
      t.references :to_user, references: :users, index: true
      t.timestamps null: false    
    end
    add_foreign_key :user_subscriptions, :users, column: :to_user_id
  end
end
