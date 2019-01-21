class AddIsPeronlityToPostTests < ActiveRecord::Migration
  def change
    add_column :post_tests, :is_personality, :boolean
  end
end
