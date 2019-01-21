class AddCountDefaultValueToVotePollOptions < ActiveRecord::Migration
  def up
    change_column_default :vote_poll_options, :count, 0
  end

  def down
    change_column_default :vote_poll_options, :count, nil
  end
end
