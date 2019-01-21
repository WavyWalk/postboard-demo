class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.text :name
      t.text :code

      t.timestamps null: false
    end
  end
end
