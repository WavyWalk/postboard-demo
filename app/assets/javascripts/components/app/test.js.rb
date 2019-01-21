module Components 
  module App
    class Test < RW
      expose

      include Plugins::Formable

      def get_initial_state
        {
          post_test: false
        }
      end

      def render
        t(:div, {},
          if n_state(:post_test)
            t(Components::PersonalityTests::Show, {post_test: n_state(:post_test)})
          end
        )
      end

      def component_did_mount
        PostTest.personality_test_show(wilds: {id: 46}).then do |post_test|
          begin
          set_state post_test: post_test
          rescue Exception => e
            p e
            raise e
          end
        end
      end


    end

  end
end
