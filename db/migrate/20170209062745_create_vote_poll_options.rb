class CreateVotePollOptions < ActiveRecord::Migration
  def change
    create_table :vote_poll_options do |t|
      t.references :post_vote_poll, index: true, foreign_key: true
      t.text :content
      t.integer :count

      t.timestamps null: false
    end
  end
end
