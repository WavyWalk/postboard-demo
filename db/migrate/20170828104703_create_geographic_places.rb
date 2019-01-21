class CreateGeographicPlaces < ActiveRecord::Migration
  def change
    create_table :geographic_places do |t|
      t.text :name
      t.belongs_to :country, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
