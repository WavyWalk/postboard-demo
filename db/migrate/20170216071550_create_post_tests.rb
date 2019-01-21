class CreatePostTests < ActiveRecord::Migration
  def change
    create_table :post_tests do |t|
      t.references :thumbnail, references: :post_image, index: true
      t.text :s_thumbnail
      t.text :s_questions
      t.references :user, index: true, foreign_key: true
      t.boolean :orphaned
      t.text :title
      t.text :test_type
    end
  end
end
