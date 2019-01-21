class AddUserIdToPostGifs < ActiveRecord::Migration
  def change
    add_reference :post_gifs, :user, index: true, foreign_key: true
  end
end
