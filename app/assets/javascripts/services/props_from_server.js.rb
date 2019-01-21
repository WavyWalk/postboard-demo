module Services
  class PropsFromServer

    def self.set_props
      @props = JSON.parse(`window.__PROPS_FROM_SERVER__`)
    end

    def self.props
      @props
    end

  end
end
