module Services
  class PhantomYielder

    def self.instance
      @instance ||= self.new
    end

    def self.instance=(val)
      @instance = val
    end

    def initialize
      @not_ready_components_count = 0
    end

    def component_in_progress
      @not_ready_components_count += 1
    end

    def component_ready
      @not_ready_components_count -= 1
      if @not_ready_components_count == 0
        inform_phantom_of_readyness
      end
    end

    def inform_phantom_of_readyness
      %x{
        if (typeof window.callPhantom === 'function') {
          window.callPhantom('components_ready');
        }
      }
      puts 'app phantom ready'
    end

  end
end