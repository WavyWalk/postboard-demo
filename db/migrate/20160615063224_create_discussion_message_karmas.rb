class CreateDiscussionMessageKarmas < ActiveRecord::Migration
  def change
    create_table :discussion_message_karmas do |t|
      t.references :discussion_message, index: true, foreign_key: true
      t.integer :count

      t.timestamps null: false
    end
  end
end
