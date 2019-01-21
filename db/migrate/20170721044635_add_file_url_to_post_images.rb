class AddFileUrlToPostImages < ActiveRecord::Migration
  def change
    add_column :post_images, :file_url, :text
  end
end
