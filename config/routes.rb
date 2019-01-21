
Rails.application.routes.draw do

  root 'home#index'

  get 'console' => 'home#console'

  get 'users/account_activation/:id' => 'users/account_activation#create'
  get 'sessions/login_via_link/:id' => 'sessions#login_via_link'

  get '/auth/:provider/callback', to: 'users#create_or_login_from_oauth_provider'
  post '/auth/:provider/callback', to: 'users#create_or_login_from_oauth_provider'

  #this path exists on middleware, is set by omniauth and handled by it
  #get '/auth/:provider'

  scope 'api' do

    get 'post_types/feed' => "post_types#feed"

    get "users/posts/index/:id" => 'users/posts#index'
    get "users/general_info/:id" => 'users/show#general_info'
    get 'users/general_info_for_current_user' => 'users/show#general_info_for_current_user'
    get "users/show/post_index/:id" => 'users/show#post_index'

    get "users/ping_current_user" => 'users#ping_current_user'
    resources :users
    post "users/:user_id/avatars" => 'users/avatars#update'


    post 'sessions/send_login_link' => 'sessions#send_login_link'
    post 'sessions/login_via_pwd' => 'sessions#login_via_pwd'
    delete 'sessions/logout' => 'sessions#logout'

    get "notifications/set_read/:id" => "notifications#set_read"
    resources :notifications
    get "users/:user_id/notifications" => "users/notifications#index"

    post 'posts/:id/titles' => 'posts/titles#update'
    namespace :posts do

      resources :discussions
      resources :discussion_messages

    end

    resources :posts

    resources :post_karma_transactions

    get 'discussion_message_karma_transactions/index_for_cu'
    resources :discussion_message_karma_transactions


    get "post_images/create_from_url" => "post_images#create_from_url"
    resources :post_images



    post 'post_gifs/add_subtitles' => 'post_gifs#add_subtitles'
    resources :post_gifs

    get 'post_vote_polls/counts/:id' => 'post_vote_polls#get_counts'

    put    'post_vote_polls/:post_vote_poll_id/content_images/:id'     => 'post_vote_polls/content_images#update'
    delete 'post_vote_polls/:post_vote_poll_id/content_images/:id'     => 'post_vote_polls/content_images#destroy'

    put    'vote_poll_options/:vote_poll_option_id/content_images/:id' => 'vote_poll_options/content_images#update'
    delete 'vote_poll_options/:vote_poll_option_id/content_images/:id' => 'vote_poll_options/content_images#destroy'

    resources :post_vote_polls do
      resources :vote_poll_options
    end


    resources :vote_poll_transactions

    #image addition to posttest related models
    put    'post_tests/:post_test_id/thumbnails/:id' => 'post_tests/thumbnails#update'

    put    'test_questions/:test_question_id/content_images/:id' => 'test_questions/content_images#update'
    delete 'test_questions/:test_question_id/content_images/:id' => 'test_questions/content_images#destroy'

    put    'test_questions/:test_question_id/on_answered_m_content_images/:id' => 'test_questions/on_answered_m_content_images#update'
    delete 'test_questions/:test_question_id/on_answered_m_content_images/:id' => 'test_questions/on_answered_m_content_images#destroy'

    put    'test_answer_variants/:test_answer_variant_id/content_images/:id' => 'test_answer_variants/content_images#update'
    delete 'test_answer_variants/:test_answer_variant_id/content_images/:id' => 'test_answer_variants/content_images#destroy'

    put    'post_test_gradations/:post_test_gradation_id/content_images/:id' => 'post_test_gradations/content_images#update'
    delete 'post_test_gradations/:post_test_gradation_id/content_images/:id' => 'post_test_gradations/content_images#destroy'


    get 'post_tests/:id' => 'post_tests#show'

    resources :post_tests do
      resources :test_questions
      resources :post_test_gradations
    end



    resources :test_questions do
      resources :test_answer_variants
    end

    resources :test_answer_variants do
      resources :personality_scales, controller: 'test_answer_variants/personality_scales'
    end

    resources :post_test_gradations

    get 'user_subscriptions/index_for_user/:id' => 'user_subscriptions#index_for_user'
    resources :user_subscriptions

    namespace :post_tags do

      resources :autocompletes

    end

    resources :post_tags



    put 'staff/user_submitted/unpublished/posts/set_published/:id' => 'staff/user_submitted/unpublished/posts#set_published'
    put 'staff/user_submitted/unpublished/posts/set_unpublished/:id' => 'staff/user_submitted/unpublished/posts#set_unpublished'

    get 'staff/posts/search' => 'staff/posts#search'
    post 'staff/user_submitted/post_karma/update_count' => 'staff/user_submitted/post_karma#update_count'


    namespace :staff do

      resources :post_texts

      resources :post_images

      resources :video_embeds

      resources :post_vote_polls

      resources :post_tests

      resources :posts

      namespace :user_submitted do

        namespace :unpublished do

          resources :posts

        end

        resources :posts


      end

    end

    resources :media_stories do
      resources :media_story_nodes, controller: 'media_stories/media_story_nodes'
    end


    resources :personality_tests do
      resources :p_t_personalities, controller: 'pt_personalities'
      resources :test_questions, controller: 'personality_tests/test_questions'
    end

    delete 'personality_tests/test_answer_variants/:id' => 'personality_tests/test_answer_variants#destroy'

    post 'personality_tests/test_answer_variants' => 'personality_tests/test_answer_variants#create'

    post '/p_t_personalities/:p_t_personality_id/medias' => 'pt_personalities/medias#update'


    resources :video_embeds

    resources :day_karma_stats

  end


  get '/system/*path' => 'home#index'

  get '/*path' => 'home#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
