class PtPersonalities::MediasController < ApplicationController

  def update
    permissions = build_permissions(P_T_Personality)
    authorize! permissions.medias_update(p_t_personality_id: params['p_t_personality_id'])

    cmpsr = ComposerFor::P_T_Personalities::Medias::Update.new(params, self)

    cmpsr.when(:ok) do |p_t_personality|
      render json: AsJsonSerializer::P_T_Personalities::Medias::Update.new(p_t_personality).success
    end

    cmpsr.when(:validation_error) do |p_t_personality|
      render json: AsJsonSerializer::P_T_Personalities::Medias::Update.new(p_t_personality).error
    end

    cmpsr.run
  end

end
