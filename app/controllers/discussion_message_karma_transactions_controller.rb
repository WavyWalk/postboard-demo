class DiscussionMessageKarmaTransactionsController < ApplicationController

  def create

    build_permissions DiscussionMessageKarmaTransaction
    authorize! @permission_rules

    cmpsr = ComposerFor::DiscussionMessageKarmaTransaction::Create::Factory
              .new(params, self)
              .create

    cmpsr.when(:ok) do |discussion_message|
      render json: AsJsonSerializer::DiscussionMessageKarmaTransaction::Create
                    .new(discussion_message)
                    .success
    end

    cmpsr.when(:validation_error) do |discussion_message|
      render json: AsJsonSerializer::DiscussionMessageKarmaTransaction::Create
                    .new(discussion_message)
                    .error
    end


    cmpsr.when(:liking_self) do |discussion_message|
      render json: AsJsonSerializer::DiscussionMessageKarmaTransaction::Create
                    .new(discussion_message)
                    .error
    end

    cmpsr.run

  end




  def index_for_cu

    discussion_message_karma_ids = params[:ids]

    current_user_id = current_user.id

    discussion_message_karma_transactions = DiscussionMessageKarmaTransaction.qo.index_for_cu_with_post_karma_ids(
      current_user_id: current_user_id, discussion_message_karma_transaction_ids: discussion_message_karma_ids
    )

    render json: AsJsonSerializer::DiscussionMessageKarmaTransaction::IndexForCu.new(discussion_message_karma_transactions).success

  end



end
