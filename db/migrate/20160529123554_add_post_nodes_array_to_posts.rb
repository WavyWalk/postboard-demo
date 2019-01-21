class AddPostNodesArrayToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :post_nodes_array, :text
  end
end
