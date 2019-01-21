class CreatePersonalityScales < ActiveRecord::Migration
  def change
    create_table :personality_scales do |t|
      t.integer :scale
      t.references :p_t_personality, index: true, foreign_key: true
      t.references :test_answer_variant, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
