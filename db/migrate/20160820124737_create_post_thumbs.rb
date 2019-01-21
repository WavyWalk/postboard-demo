class CreatePostThumbs < ActiveRecord::Migration
  def change
    create_table :post_thumbs do |t|
      t.references :node, polymorphic: true, index: true
      t.references :post, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
