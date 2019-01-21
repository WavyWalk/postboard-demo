class ComposerFor::PostTests::Create < ComposerFor::Base

  def initialize(params, controller)
    @params = params
    @controller = controller
  end

  def before_compose
    set_permitted_attributes
    build_and_set_post_test
    run_validations
  end

  def set_permitted_attributes
    @permitted_attributes = @params.require('post_test').permit(
      'title',
      {
        'thumbnail' => [
          'id'
        ]  
      },
      {
        'test_questions' => [
          'text',
          'content_type',
          'on_answered_m_content_type',
          'question_type', #unused for now
          'on_answered_msg',
          {
            'content' => [ 
              'id'
            ]
          },
          {
            'on_answered_m_content' => [
              'id'
            ]
          },
          {
            'test_answer_variants' => [
              'text',
              'answer_type',
              'content_type',
              'correct',
              'on_select_message',
              'content' => [
                'id'
              ]
            ]
          }
        ]
      },
      {
        'post_test_gradations' => [
          'from',
          'to',
          'message',
          'content_type',
          'content' => [
            'id'
          ]
        ]
      }
      
    )
  end

  def build_and_set_post_test
    test_factory = PostTest
                    .factory.new
                    .initialize_for_create(@permitted_attributes)
                    .add_user_id(@controller.current_user.id)
                    .add_test_questions( build_test_questions(@permitted_attributes['test_questions']) )
                    .add_post_test_gradations( build_test_gradations( @permitted_attributes['post_test_gradations'] ) )
    

    @post_test = test_factory.get_result

  end


  def build_test_questions(attributes)
    attributes ||= []
    test_questions = []

    attributes.each do |question_attributes|
    
      test_question_factory = TestQuestion.factory.new
                .initialize_for_test_create(question_attributes)
      
      
      test_question_factory.add_test_answer_variants( build_test_answer_variants(question_attributes['test_answer_variants']) )
      

      test_questions << test_question_factory.get_result
    
    end

    test_questions

  end

  def build_test_answer_variants(attributes)
    attributes ||= []
    variants = []
    attributes.each do |variant_attributes|

      factory = TestAnswerVariant.factory.new
        .initialize_for_test_create(variant_attributes)
      
      variants << factory.get_result
    end
    variants
  end

  def build_test_gradations(attributes)
    attributes ||= []
    post_test_gradations = []
    attributes.each do |gradation_attributes|

      factory = PostTestGradation.factory.new
                .initialize_for_test_create(gradation_attributes)

      post_test_gradations << factory.get_result

    end
    post_test_gradations
  end

  def run_validations
    #validates associated in validator
    @post_test.validation_service.set_scenarios(:create).validate
  end

  def compose
    @post_test.save!
    set_orphaned_resources_unorphaned!
    #serialize_necessary_fields!
  end

  # def serialize_necessary_fields!
  #   @post_test.updater.serialize_necessary_fields
  #   @post_test.save!
  # end

  def set_orphaned_resources_unorphaned!
    images = []
    
    @post_test.post_test_gradations.each do |grad|
      if grad.content_type == 'PostImage'
        images << grad.content
      end
    end 
    @post_test.test_questions.each do |ques|
      if ques.content_type == 'PostImage'
        images << ques.content
      end
      if ques.on_answered_m_content_type == 'PostImage'
        images << ques.on_answered_m_content
      end
      ques.test_answer_variants.each do |var|
        if var.content_type == 'PostImage'
          images << var.content
        end
      end
    end

    images.each do |image|
      if image.orphaned
        image.orphaned = false
        image.save!
      end
    end
  end

  def resolve_success
    publish(:ok, @post_test)
  end

  def resolve_fail(e)
    
    case e
    when ActiveRecord::RecordInvalid
      publish(:validation_error, @post_test)
    else
      raise e
    end

  end

end
