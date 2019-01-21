class RenamePostNodesArrayInPostsToNodesOrder < ActiveRecord::Migration


  def self.up
    rename_column :posts, :post_nodes_array, :nodes_order
  end

  def self.down
    rename_column :posts, :nodes_order, :post_nodes_array
  end


end
