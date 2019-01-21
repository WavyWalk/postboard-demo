class PostKarmaTransactionsController < ApplicationController

  def create
    
    build_permissions PostKarmaTransaction
    authorize! @permission_rules

    cmpsr = ComposerFor::PostKarmaTransaction::Create::Factory
              .new(params, self)
              .create

    cmpsr.when(:ok) do |post_karma_transaction|
      render json: AsJsonSerializer::PostKarmaTransaction::Create
                    .new(post_karma_transaction)
                    .success
    end

    cmpsr.when(:validation_error) do |post_karma_transaction|
      render json: AsJsonSerializer::PostKarmaTransaction::Create
                    .new(post_karma_transaction)
                    .error
    end


    cmpsr.when(:liking_self) do |post_karma_transaction|
      render json: AsJsonSerializer::PostKarmaTransaction::Create
                    .new(post_karma_transaction)
                    .error      
    end


    cmpsr.run

  end

end
 