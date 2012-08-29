module Pure
  module EventBus

    class Subscriber

      module ClassMethods
        attr_reader :event_handlers

        def on_event(event_name, &block)
          event_handlers[event_name] ||= []
          event_handlers[event_name] << block
        end

        def event_handlers
          @event_handlers ||= {}
        end
      end

      def self.inherited(klass)
        klass.extend(ClassMethods)
      end

      def notify(event)
        return if self.class.event_handlers[event.name].nil?
        
        self.class.event_handlers[event.name].each do |handler|
          instance_exec(event.attributes, &handler)
        end
      end
    end

  end
end