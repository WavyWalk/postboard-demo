module Plugins
  module RWGlobalExtensions

    #renders general errors for provided model
    def general_errors_for(model)
      if model && model.errors[:general]
        t(:div, {className: 'invalid'},
          model.errors[:general].map do |error|
            t(:p, {}, error)
          end
        )
      end
    end

    def start_spinning_icon
      Components::Shared::LoadIconPool.instance.create_load_icon(self)
    end

    def stop_spinning_icon
      Components::Shared::LoadIconPool.instance.destroy_load_icon(self)
    end

  end
end
