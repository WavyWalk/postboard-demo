class CreateUserDenormalizedStats < ActiveRecord::Migration
  def change
    create_table :user_denormalized_stats do |t|
      t.integer :subscribers_count, default: 0
      t.integer :comments_count, default: 0
      t.integer :karma_count, default: 0
      t.integer :posts_count, default: 0
      t.integer :subscriptions_count, default: 0
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
