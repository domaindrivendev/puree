module Puree
  module EventBus

    class Subscriber

      module ClassMethods
        def on_event(name, &block)
          on_event_blocks[name] = block
        end

        def event_names
          on_event_blocks.keys
        end

        def on_event_blocks
          @on_event_blocks ||= {}
        end
      end

      def self.inherited(klass)
        klass.extend(ClassMethods)
      end

      def event_names
        self.class.event_names
      end

      def notify(event)
        on_event_blocks = self.class.on_event_blocks
        if on_event_blocks[event.name].nil?
          raise "Failed to handle event - no on_event block found for #{event.name}"
        end
        instance_exec(event, &on_event_blocks[event.name])
      end

    end

  end
end