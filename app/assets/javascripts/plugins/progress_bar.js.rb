module Plugins

  module ProgressBar

    def has_progress_bar
      @has_progress_bar
    end

    def progress_bar
      @has_progress_bar = true
      t(Shared::ProgressBar, {ref: 'progress_bar'})
    end

    def progress_bar_instance
      if ref('progress_bar')
        ref('progress_bar').rb
      end
    end

  end

end