class CreateDiscussions < ActiveRecord::Migration
  def change
    create_table :discussions do |t|
      t.references :discussable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
