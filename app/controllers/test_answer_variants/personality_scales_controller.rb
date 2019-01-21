class TestAnswerVariants::PersonalityScalesController < ApplicationController

  def update
    test_question_id = params['id']

    permission_rules = Permissions::PersonalityScaleRules.new(PersonalityScale, self)
    authorize! permission_rules.update(test_question_id: test_question_id)

    cmpsr = ComposerFor::TestAnswerVariants::PersonalityScales::Update.new(self)

    cmpsr.when(:ok) do |personality_scale|
      render json: personality_scale.to_json
    end

    cmpsr.when(:validation_error) do |personality_scale|
      render json: personality_scale.to_json(methods: [:errors])
    end

    cmpsr.run
  end

end
