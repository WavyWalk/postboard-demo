class CreatePostTestGradations < ActiveRecord::Migration
  def change
    create_table :post_test_gradations do |t|
      t.integer :from
      t.integer :to
      t.references :post_test, index: true, foreign_key: true
      t.references :content, polymorphic: true, index: true
      t.text :message

      t.timestamps null: false
    end
  end
end
