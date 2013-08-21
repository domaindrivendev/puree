module Puree
  module Messaging

    class InMemoryBus

      def initialize
        @subscribers = []
      end

      def subscribe(subscriber)
        @subscribers << subscriber
      end

      def publish(event)
        @subscribers.each do |subscriber|
          if subscriber.subscribes_to?(event.name)
            subscriber.notify(event)
          end
        end 
      end
    end

  end
end