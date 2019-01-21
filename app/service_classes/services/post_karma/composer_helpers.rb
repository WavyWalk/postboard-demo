class Services::PostKarma::ComposerHelpers

  def self.refine_hot_since(post_karma)
    if post_karma.count > 49 && !post_karma.hot_since
      post_karma.hot_since = Time.now
    elsif post_karma.count < 50 && post_karma.hot_since
      post_karma.hot_since = nil
    end
    post_karma
  end

end