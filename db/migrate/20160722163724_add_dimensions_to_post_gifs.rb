class AddDimensionsToPostGifs < ActiveRecord::Migration
  def change
    add_column :post_gifs, :dimensions, :text
  end
end
