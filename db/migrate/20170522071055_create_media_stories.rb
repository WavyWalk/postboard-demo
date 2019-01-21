class CreateMediaStories < ActiveRecord::Migration
  def change
    create_table :media_stories do |t|
      t.text :title
      t.references :user, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
