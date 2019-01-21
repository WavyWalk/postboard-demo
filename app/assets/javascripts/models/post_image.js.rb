class PostImage < Model

  register


  attributes :id, :post_size_url, :file, :dimensions,
             :post_node_id, :base_url, :file_url, :source_name,
             :source_link, :alt_text

  route 'create', post: 'post_images'

  route 'update_thumbnail', put: 'post_tests/:post_test_id/thumbnails/:id'

  route 'update_test_question_as_content',            {put: 'test_questions/:test_question_id/content_images/:id'},               {defaults: [:id]}
  route 'update_test_question_as_on_answered_content',{put: 'test_questions/:test_question_id/on_answered_m_content_images/:id'}, {defaults: [:id]}
  route 'update_test_answer_variant_as_content',      {put: 'test_answer_variants/:test_answer_variant_id/content_images/:id'},   {defaults: [:id]}
  route 'update_post_test_gradation_as_content',      {put: 'post_test_gradations/:post_test_gradation_id/content_images/:id'},   {defaults: [:id]}
  route 'update_post_vote_poll_as_content',           {put: 'post_vote_polls/:post_vote_poll_id/content_images/:id'},             {defaults: [:id]}
  route 'update_vote_poll_option_as_content',         {put: 'vote_poll_options/:vote_poll_option_id/content_images/:id'},         {defaults: [:id]}

  route 'remove_from_test_question',                          {delete: 'test_questions/:test_question_id/content_images/:id'},               {defaults: [:id]}
  route 'remove_from_test_question_as_on_answered_m_content', {delete: 'test_questions/:test_question_id/on_answered_m_content_images/:id'}, {defaults: [:id]}
  route 'remove_from_test_answer_variant',                    {delete: 'test_answer_variants/:test_answer_variant_id/content_images/:id'},   {defaults: [:id]}
  route 'remove_from_post_test_gradation',                    {delete: 'post_test_gradations/:post_test_gradation_id/content_images/:id'},   {defaults: [:id]}
  route 'remove_from_post_vote_poll',                         {delete: 'post_vote_polls/:post_vote_poll_id/content_images/:id'},             {defaults: [:id]}
  route 'remove_from_vote_poll_option',                       {delete: 'vote_poll_options/:vote_poll_option_id/content_images/:id'},         {defaults: [:id]}

  route 'Create_from_url', {get: "post_images/create_from_url"}

  route :destroy, {delete: 'post_images/:id'}, {defaults: [:id]}

  def self.after_route_create_from_url(r)
    json = r.response.json
    r.promise.resolve(json)
  end

  def post_size_url
    if !file_url
      p "warning! #{self}#{self.class.name} does not have file_url attribute"
    end
    url = self.file_url
    if url
      url.gsub('/original/', '/post_size/')
    elsif base_url
      base_url.gsub('/original/', '/post_size/')
    else
      attributes[:post_size_url]
    end
  end

  def after_route_create(r)
    if r.response.ok?
      json_response = r.response.json
      self.update_attributes(json_response)
      self.validate
      unless self.has_errors?
        self.attributes.delete(:file)
      end
      r.promise.resolve self
    end
  end

  def before_route_update_thumbnail(r)
    self.before_route_update(r)
  end

  def after_route_update_thumbnail(r)
    self.after_route_update(r)
  end

  def before_route_update_test_question_as_content(r)
    self.before_route_update(r)
  end

  def after_route_update_test_question_as_content(r)
    self.after_route_update(r)
  end

  def before_route_update_test_question_as_on_answered_content(r)
    self.before_route_update(r)
  end

  def after_route_update_test_question_as_on_answered_content(r)
    self.after_route_update(r)
  end

  def before_route_update_test_answer_variant_as_content(r)
    self.before_route_update(r)
  end

  def after_route_update_test_answer_variant_as_content(r)
    self.after_route_update(r)
  end

  def before_route_update_post_test_gradation_as_content(r)
    self.before_route_update(r)
  end

  def after_route_update_post_test_gradation_as_content(r)
    self.after_route_update(r)
  end

  def after_route_update_post_vote_poll_as_content(r)
    self.after_route_update(r)
  end

  def after_route_update_vote_poll_option_as_content(r)
    self.after_route_update(r)
  end

  # def before_route_remove_from_test_question(r)
  #   self.before_route_destroy(r)
  # end

  def after_route_remove_from_test_question(r)
    self.after_route_destroy(r)
  end

  def after_route_remove_from_test_question_as_on_answered_m_content(r)
    self.after_route_destroy(r)
  end

  def after_route_remove_from_test_answer_variant(r)
    self.after_route_destroy(r)
  end

  def after_route_remove_from_post_test_gradation(r)
    self.after_route_destroy(r)
  end

  def after_route_remove_from_post_vote_poll(r)
    self.after_route_destroy(r)
  end

  def after_route_remove_from_vote_poll_option(r)
    self.after_route_destroy(r)
  end

  def validate_file
    self.has_file = true
  end

end
