class CreatePostTagLinks < ActiveRecord::Migration
  def change
    create_table :post_tag_links do |t|
      t.references :post, index: true, foreign_key: true
      t.references :post_tag, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
