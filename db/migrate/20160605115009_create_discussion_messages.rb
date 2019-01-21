class CreateDiscussionMessages < ActiveRecord::Migration
  def change
    create_table :discussion_messages do |t|
      t.references :user, index: true, foreign_key: true
      t.text :content
      t.references :discussion_message, index: true, foreign_key: true
      t.references :discussion, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
