class AddSNodesToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :s_nodes, :text
  end
end
