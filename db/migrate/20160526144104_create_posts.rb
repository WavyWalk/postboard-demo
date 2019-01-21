class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text :content
      t.boolean :published, index: true
      t.timestamp :published_at
      t.references :author, references: :users, index: true

      t.timestamps null: false
    end
  end
end
