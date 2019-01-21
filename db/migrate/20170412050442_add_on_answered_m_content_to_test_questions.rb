class AddOnAnsweredMContentToTestQuestions < ActiveRecord::Migration
  def change
    add_reference :test_questions, :on_answered_m_content, polymorphic: true, index: {name: 'idx_on_tq_on_answ_cont'}
    add_column :test_questions, :s_on_answered_m_content, :text
    add_column :test_questions, :on_answered_msg, :text
  end
end
