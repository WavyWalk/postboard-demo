class CreatePostKarmas < ActiveRecord::Migration
  def change
    create_table :post_karmas do |t|
      t.references :post, index: true, foreign_key: true
      t.integer :count

      t.timestamps null: false
    end
  end
end
