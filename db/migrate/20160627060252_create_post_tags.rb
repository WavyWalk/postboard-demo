class CreatePostTags < ActiveRecord::Migration
  def change
    create_table :post_tags do |t|
      t.text :name

      t.timestamps null: false
    end
    add_index :post_tags, :name
  end
end
