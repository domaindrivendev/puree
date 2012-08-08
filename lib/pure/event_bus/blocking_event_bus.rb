require 'pure/event_bus/listener'

module Pure
  module EventBus

    class BlockingEventBus

      def initialize
        @all_listeners = {}
      end

      def register_listener(listener)
        event_name = listener.event_name

        @all_listeners[event_name] = [] unless @all_listeners.has_key?(event_name)
        @all_listeners[event_name] << listener
      end

      def publish(event)
        listeners = @all_listeners[event.name]

        return if listeners.nil?

        listeners.each { |listener| listener.notify(event) }
      end

    end

  end
end