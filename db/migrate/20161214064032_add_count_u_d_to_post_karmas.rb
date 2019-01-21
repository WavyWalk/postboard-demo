class AddCountUDToPostKarmas < ActiveRecord::Migration
  def change
    add_column :post_karmas, :count_u, :integer
    add_column :post_karmas, :count_d, :integer
  end
end
