class VotePollTransactionsController < ApplicationController

  def create
    
    permissions = build_permissions VotePollTransaction

    authorize! permissions

    cmpsr = ComposerFor::VotePollTransaction::Create.new(params, self)

    cmpsr.when(:ok) do |transaction|
      render json: transaction.as_json
    end

    cmpsr.when(:transaction_exists) do |transaction|
      render json: transaction.as_json(methods: [:errors])
    end

    cmpsr.run

  end

end