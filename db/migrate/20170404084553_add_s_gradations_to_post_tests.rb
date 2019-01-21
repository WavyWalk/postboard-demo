class AddSGradationsToPostTests < ActiveRecord::Migration
  def change
    add_column :post_tests, :s_gradations, :text
  end
end
