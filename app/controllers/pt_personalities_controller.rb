class PtPersonalitiesController < ApplicationController

  def create 
    permissions = build_permissions(P_T_Personality)
    authorize! permissions.create(post_test_id: params['personality_test_id'])

    cmpsr = ComposerFor::P_T_Personalities::Create.new(params, self)

    cmpsr.when(:ok) do |p_t_personality|
      render json: AsJsonSerializer::P_T_Personalities::Create.new(p_t_personality).success
    end

    cmpsr.when(:validation_error) do |p_t_personality|
      render json: AsJsonSerializer::P_T_Personalities::Create.new(p_t_personality).error
    end

    cmpsr.run
    
  end

  def destroy
    permissions = build_permissions(P_T_Personality)
    authorize! permissions.destroy(post_test_id: params['personality_test_id'])

    cmpsr = ComposerFor::P_T_Personalities::Destroy.new(self)

    cmpsr.when(:ok) do |p_t_personality|
      render json: AsJsonSerializer::P_T_Personalities::Destroy.new(p_t_personality).success
    end

    cmpsr.when(:validation_error) do |p_t_personality|
      render json: AsJsonSerializer::P_T_Personalities::Destroy.new(p_t_personality).error
    end

    cmpsr.run
  end

  def update
    permissions = build_permissions(P_T_Personality)
    authorize! permissions.update(post_test_id: params['personality_test_id'])

    cmpsr = ComposerFor::P_T_Personalities::Update.new(params, self)

    cmpsr.when(:ok) do |p_t_personality|
      render json: AsJsonSerializer::P_T_Personalities::Update.new(p_t_personality).success
    end

    cmpsr.when(:validation_error) do |p_t_personality|
      render json: AsJsonSerializer::P_T_Personalities::Update.new(p_t_personality).error
    end

    cmpsr.run
  end

end
