class AddPolymorphicMediaContentRefToPostVotePolls < ActiveRecord::Migration
  def change
    add_reference :post_vote_polls, :m_content, polymorphic: true, index: true
  end
end
