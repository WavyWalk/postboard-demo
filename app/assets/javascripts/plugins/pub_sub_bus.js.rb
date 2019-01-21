module Plugins
  module PubSubBus

      def when(channel, &block)
        @block_channels ||= Hash.new { |k, v| k[v] = [] }
        @block_channels[channel] << block
      end

      def subscribe(channel, obj)
        @pub_sub_list ||= Hash.new { |h, k| h[k] = [] }
        @pub_sub_list[channel] << obj unless @pub_sub_list[channel].include?(obj)
      end

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

      def unsubscribe(channel, obj)
        x = @pub_sub_list[channel].delete(obj)
        raise "#{obj} tried to #{self}.unsub_from #{channel} which is not in list" unless x
      end

      def unsubscribe_all(channel = false)
        if channel
          @pub_sub_list[channel] = []
        else
          @pub_sub_list = Hash.new { |h, k| h[k] = []}
          @block_channels = Hash.new { |k, v| k[v] = [] }
        end
      end

  end
end
