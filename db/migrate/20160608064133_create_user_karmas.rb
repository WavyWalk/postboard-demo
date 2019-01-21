class CreateUserKarmas < ActiveRecord::Migration
  def change
    create_table :user_karmas do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :count

      t.timestamps null: false
    end
  end
end
