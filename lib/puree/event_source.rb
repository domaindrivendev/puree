module Puree

  class EventSource

    module ClassMethods
      attr_reader :identifier_name

      def identifier(name)
        attr_reader(name)
        @identifier_name = name
      end

      def apply_event(name, &block)
        event_handlers[name] = block
      end

      def event_handlers
        @event_handlers ||= {}
      end
    end

    def self.inherited(klass)
      klass.extend(ClassMethods)
    end

    def signal_event(name, args={})
      event = Event.new(name, args)
      apply(event)

      @pending_events ||= []
      @pending_events << event
    end

    def replay(event)
      apply(event)
    end

    def pending_events
      @pending_events ||= []
      @pending_events.freeze
    end

    private

      def apply(event)
        event_handlers = self.class.event_handlers
        raise EventHandlerNotFound.new(event.name) unless event_handlers.has_key?(event.name)

        instance_exec(event.args, &event_handlers[event.name])
      end
  end

  class Event
    attr_reader :name, :args

    def initialize(name, args)
      @name = name
      @args = args
    end
  end

  class EventHandlerNotFound < RuntimeError
    def initialize(event_name)
      super("Event handler not found for event - #{event_name}")
    end
  end

end