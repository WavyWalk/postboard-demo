class AddMediaContentPolymRefToVotePollOptions < ActiveRecord::Migration
  def change
    add_reference :vote_poll_options, :m_content, polymorphic: true, index: true
  end
end
