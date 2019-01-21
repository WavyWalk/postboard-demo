class CreateTestQuestions < ActiveRecord::Migration
  def change
    create_table :test_questions do |t|
      t.references :post_test, index: true, foreign_key: true
      t.references :content, polymorphic: true, index: true
      t.text :s_content
      t.text :s_test_answer_variants
      t.text :text
      t.text :on_wrong_select_msg
      t.text :question_type
    end
  end
end
