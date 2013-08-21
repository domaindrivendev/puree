module Puree
  module Messaging

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
    
      def subscribes_to?(event_name)
        self.class.event_names.include?(event_name)
      end

      def notify(event)
        on_event_blocks = self.class.on_event_blocks
        instance_exec(event.args, &on_event_blocks[event.name])
      end
    end

  end
end