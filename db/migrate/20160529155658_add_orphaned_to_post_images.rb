class AddOrphanedToPostImages < ActiveRecord::Migration
  def change
    add_column :post_images, :orphaned, :boolean
  end
end
