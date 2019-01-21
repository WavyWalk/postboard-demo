class CreatePostNodes < ActiveRecord::Migration
  def change
    create_table :post_nodes do |t|
      t.references :post, index: true, foreign_key: true
      t.references :node, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
