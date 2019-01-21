class CreatePostTsvs < ActiveRecord::Migration
  def change
    create_table :post_tsvs do |t|
      t.string :content
      t.references :post, index: true, foreign_key: true
      t.references :searchable, polymorphic: true, index: true
      t.timestamps null: false
    end
  end
end
