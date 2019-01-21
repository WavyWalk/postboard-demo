module Components 
  module PersonalityTests
    class Show < RW
      expose

      def validate_props
        #post_test : PostTest (is_persoanlity: true) - required
      end

      def get_initial_state
        p 'gon render personality_test/show'
        post_test = n_prop(:post_test)

        questions_left_to_answer = post_test.test_questions.data.length

        answer_tracker = prepare_answer_tracker(post_test)

        populate_variant_scales_with_personalities(post_test) 
        
        {
          post_test: post_test,
          answer_tracker: answer_tracker,
          questions_left_to_answer: questions_left_to_answer,
          leading_personality: false,
          completed: false
        }
      end

      def prepare_answer_tracker(post_test)
        answer_tracker = {}
        post_test.test_questions.each do |test_question|
          answer_tracker[test_question] = nil
        end
        answer_tracker
      end

      def populate_variant_scales_with_personalities(post_test)
        personalities_mapped_by_id = {}
        post_test.p_t_personalities.each do |personality_scale|
          personalities_mapped_by_id[personality_scale.id] = personality_scale
        end
        post_test.test_questions.each do |test_question|
          test_question.test_answer_variants.each do |variant|
            variant.personality_scales.each do |personality_scale|
              personality_to_assign = personalities_mapped_by_id[personality_scale.p_t_personality_id]
              personality_scale.p_t_personality = personality_to_assign
            end
          end
        end
        post_test
      end

      def render
        post_test = n_state(:post_test)

        t(:div, {className: 'PostTests-Show PersonalityTests'}, 
          t(:h2, {className: 'title'}, post_test.title),

          t(Components::PostImages::Show, 
            {
              post_image: post_test.thumbnail, css_class: 'thumbnail'
            }
          ),

          t(:div, {className: 'questionsContainer'},
            post_test.test_questions.data.map do |question|              
              t(Components::PersonalityTests::Questions::Show, 
                {
                  key: question.id,
                  question: question,
                  on_answered: ->(question, variant){on_answered(question, variant)},
                  test_completed: n_state(:completed)
                }
              )
            end
          ),

          if n_state(:completed) 
            t(:div, {className: 'personalityReveal'},
              "rev",
              t(:p, {className: 'title'}, n_state(:leading_personality).title),
              t(:div, {className: 'media'},
                case media = n_state(:leading_personality).media
                when PostImage
                  t(Components::PostImages::Show, {post_image: media})
                when PostGif
                  t(Components::PostGifs::Show, {post_gif: media})
                when VideoEmbed
                  t(Components::VideoEmbeds::Show, {video_embed: media})
                end
              )
            )
          end
        ) 
      end

      def on_answered(question, variant)
        n_state(:answer_tracker)[question] = variant
        decrement_questions_left_to_answer
      end

      def decrement_questions_left_to_answer
        count = n_state(:questions_left_to_answer) - 1
        if count == 0
          leading_personality = calculate_leading_personality
          set_state(completed: true, questions_left_to_answer: count, leading_personality: leading_personality)
        else
          set_state(questions_left_to_answer: count)
        end
      end

      def calculate_leading_personality
        post_test = n_state(:post_test)

        personality_to_count = Hash.new { |hash, key| hash[key] = 0 }
        
        n_state(:answer_tracker).each do |question, variant|
          variant.personality_scales.data.each do |personality_scale|       
            personality_to_count[personality_scale.p_t_personality] += personality_scale.scale
          end
        end

        greatest_count_so_far = 0
        greatest_personality = nil
        personality_to_count.each do |personality, count|
          if count > greatest_count_so_far
            greatest_count_so_far = count
            greatest_personality = personality
          end
        end

        greatest_personality

      end

    end
  end
end