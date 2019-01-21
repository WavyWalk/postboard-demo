class AddSourceAndAltToPostImages < ActiveRecord::Migration
  def change
    add_column :post_images, :source_name, :text
    add_column :post_images, :source_link, :text
    add_column :post_images, :alt_text, :text
  end
end
