class CreatePostTestStats < ActiveRecord::Migration
  def change
    create_table :post_test_stats do |t|
      t.integer :from
      t.integer :to
      t.integer :count
      t.references :post_test, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
