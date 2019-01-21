class AddDimensionsToPostImages < ActiveRecord::Migration
  def change
    add_column :post_images, :dimensions, :text
  end
end
