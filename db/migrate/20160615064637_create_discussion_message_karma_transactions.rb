class CreateDiscussionMessageKarmaTransactions < ActiveRecord::Migration
  def change
    create_table :discussion_message_karma_transactions do |t|
      t.references :discussion_message_karma, index: {name: 'dmkt_on_dmk'}, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.integer :amount
      t.string :cancel_type

      t.timestamps null: false
    end
  end
end
