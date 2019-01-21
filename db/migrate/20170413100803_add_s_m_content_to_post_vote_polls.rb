class AddSMContentToPostVotePolls < ActiveRecord::Migration
  def change
    add_column :post_vote_polls, :s_m_content, :text
  end
end
