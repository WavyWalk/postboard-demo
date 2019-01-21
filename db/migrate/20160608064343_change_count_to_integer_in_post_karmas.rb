class ChangeCountToIntegerInPostKarmas < ActiveRecord::Migration
  def change

    change_column :post_karmas, :count, :integer

  end
end
