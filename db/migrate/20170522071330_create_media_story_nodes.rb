class CreateMediaStoryNodes < ActiveRecord::Migration
  def change
    create_table :media_story_nodes do |t|
      t.references :media_story, index: true, foreign_key: true
      t.references :media, polymorphic: true, index: true
      t.text :annotation

      t.timestamps null: false
    end
  end
end
