class CreatePTPersonalities < ActiveRecord::Migration
  def change
    create_table :p_t_personalities do |t|
      t.text :title
      t.references :media, polymorphic: true, index: true
      t.references :post_test, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
