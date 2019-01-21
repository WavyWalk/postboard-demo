module Services
  module PubSubBus
    module Publisher

      #subscribe block to some channel that will be called on that channel publishing
      #eg
      # (_sp = SomePublisher).new.when(:done) { |msg|
      #   from_block_scope_do_shit_with(msg)
      # }
      #
      # _sp.do_some_bizzare_calculations
      #
      # _sp.publish(:done, "yay!")
      # #that block'll be called
      def when(channel, &block)
        @block_channels ||= Hash.new { |k, v| k[v] = [] }
        @block_channels[channel] << block
      end

      #puts object to subcribed list on specific channel
      # sp  = SomePublisher.new
      # sp.subscribe(:on_foo, self)
      # sp.do_some_bizzare_calculations
      # sp.publish(:on_foo, "lol")
      # #self.on_foo("lol") will be called
      def subscribe(channel, obj)
        @pub_sub_list = Hash.new { |h, k| h[k] = [] }
        @pub_sub_list[channel] << obj unless @pub_sub_list[channel].include?(obj)
      end

      #publishes to subscribed objects and blocks in channel with *args
      def publish(channel, *args)
        if @pub_sub_list
          @pub_sub_list[channel].each do |obj|
            begin
            obj.send(channel, *args)
            rescue NoMethodError => e
              raise "#{self} tried to publish to #{channel} but #{obj} doesn't implement it: #{e}"
            end
          end
        end
        if @block_channels
          @block_channels[channel].each do |block|
            block.call(*args)
          end
        end
      end

      #ubsubscribe specific oject on specific channel
      def unsubscribe(channel, obj)
        x = @pub_sub_list[channel].delete(obj)
        raise "#{obj} tried to #{self}.unsub_from #{channel} which is not in list" unless x
      end

      #unsubscribe all
      def unsubscribe_all(channel = false)
        if channel
          @pub_sub_list[channel] = []
        else
          @pub_sub_list = Hash.new { |h, k| h[k] = []}
          @block_channels = Hash.new { |k, v| k[v] = [] }
        end
      end

    end

    #it's more of an interface, and by most is not required, map your both class and insatance channels (methods that resemble channel name)
    # #eg
    # extend Services::PubSubBus::Subscriber
    #
    # implemented_channels (
    #   {
    #     class: [:on_foo],
    #     instance: [:on_bar]
    #   }
    # )
    #
    # def self.on_foo(msg)
    #   do_some_shit_with msg
    # end
    #
    # #on_bar not implemented; so it'll raise

    module Subscriber
      def implemented_channels(arg)
        @implemented_channels = {}
        @implemented_channels[:class] = []
        @implemented_channels[:instance] = []
        @implemented_channels[:class].each do |channel|
          raise "class channel #{channel} not implemented for #{self} but declared as so" unless self.respond_to? channel
        end
        @implemented_channels[:instance].each do |channel|
          raise "instance channel #{channel} not implemented for #{self} but declared as so" unless self.method_defined? channel
        end
      end
    end

  end
end
