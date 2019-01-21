class AddCancelTypeToPostKarmaTransactions < ActiveRecord::Migration
  def change
    add_column :post_karma_transactions, :cancel_type, :string
  end
end
