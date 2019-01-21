class CreateDayKarmaEvents < ActiveRecord::Migration
  def change
    create_table :day_karma_events do |t|
      t.references :day_karma_stat, index: true, foreign_key: true
      t.integer :up_count, default: 0
      t.integer :down_count, default: 0
      t.references :source, polymorphic: true, index: true
      t.integer :event_type
      t.references :user, index: true, foreign_key: true
      t.text :source_text

      t.timestamps null: false
    end
  end
end
