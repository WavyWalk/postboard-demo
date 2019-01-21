class CreatePostKarmaTransactions < ActiveRecord::Migration
  def change
    create_table :post_karma_transactions do |t|
      t.references :post_karma, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.integer :amount

      t.timestamps null: false
    end
  end
end
