class CreatePostVotePolls < ActiveRecord::Migration
  def change
    create_table :post_vote_polls do |t|
      t.text :question 
      t.text :s_options
      t.integer :count
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
