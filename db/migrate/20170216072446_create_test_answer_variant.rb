class CreateTestAnswerVariant < ActiveRecord::Migration
  def change
    create_table :test_answer_variants do |t|
      t.references :test_question, index: true, foreign_key: true
      t.text :s_content
      t.references :content, polymorphic: true, index: true
      t.text :answer_type
      t.boolean :correct
      t.text :text
      t.text :on_select_message
    end
  end
end
