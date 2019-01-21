class AddOrphanedToPostGifs < ActiveRecord::Migration
  def change
    add_column :post_gifs, :orphaned, :boolean
  end
end
