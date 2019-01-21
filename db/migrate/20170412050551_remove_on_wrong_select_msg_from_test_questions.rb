class RemoveOnWrongSelectMsgFromTestQuestions < ActiveRecord::Migration
  def change
    remove_column :test_questions, :on_wrong_select_msg, :text
  end
end
