class CreateVotePollTransactions < ActiveRecord::Migration
  def change
    create_table :vote_poll_transactions do |t|
      t.references :post_vote_poll, index: true, foreign_key: true
      t.integer :vote_poll_option_id
      t.references :user, index: true, foreign_key: true
      t.boolean :type

      t.timestamps null: false
    end
  end
end
