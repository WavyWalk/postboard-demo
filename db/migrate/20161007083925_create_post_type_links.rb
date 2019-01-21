class CreatePostTypeLinks < ActiveRecord::Migration
  def change
    create_table :post_type_links do |t|
      t.references :post, index: true, foreign_key: true
      t.references :post_type, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
