class CreateDayKarmaStats < ActiveRecord::Migration
  def change
    create_table :day_karma_stats do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :up_count, default: 0
      t.integer :down_count, default: 0

      t.timestamps null: false
    end
  end
end
