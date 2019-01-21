class AddMessagesCountToDiscussions < ActiveRecord::Migration
  def change
    add_column :discussions, :messages_count, :integer, default: 0
  end
end
