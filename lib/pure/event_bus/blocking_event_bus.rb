require 'pure/event_bus/subscriber'

module Pure
  module EventBus

    class BlockingEventBus

      def initialize
        @subscribers = {}
      end

      def register(subscriber)
        subscriber.class.event_handlers.keys.each do |event_name|
          @subscribers[event_name] ||= []
          @subscribers[event_name] << subscriber
      end

      end

      def publish(event)
        event_subscribers = @subscribers[event.name]

        unless event_subscribers.nil?
          event_subscribers.each do |subscriber|
            subscriber.notify(event)
          end
        end
      end

    end

  end
end