class CreatePostGifs < ActiveRecord::Migration
  def change
    create_table :post_gifs do |t|

      t.timestamps null: false
    end
  end
end
