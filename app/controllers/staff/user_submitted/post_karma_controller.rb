class Staff::UserSubmitted::PostKarmaController < ApplicationController

  def update_count
    build_permissions PostKarma

    authorize! @permission_rules.staff_count_update

    cmpsr = ComposerFor::Staff::UserSubmitted::PostKarma::CountUpdate.new(params: params, controller: self)

    cmpsr.when(:ok) do |post_karma|
      render json: post_karma
    end

    cmpsr.when(:post_karma_not_found) do |post_karma|
        
      render json: post_karma.as_json(methods: [:errors])

    end

    cmpsr.run

  end

end
