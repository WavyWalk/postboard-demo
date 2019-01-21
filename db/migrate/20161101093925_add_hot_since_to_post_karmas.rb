class AddHotSinceToPostKarmas < ActiveRecord::Migration
  def change
    add_column :post_karmas, :hot_since, :datetime
  end
end
