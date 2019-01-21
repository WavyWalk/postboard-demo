class AddSpecialToPostTags < ActiveRecord::Migration
  def change
    add_column :post_tags, :special, :bool
    add_index :post_tags, :special
  end
end
