class AddOrphanedToPostVotePolls < ActiveRecord::Migration
  def change
    add_column :post_vote_polls, :orphaned, :boolean
  end
end
