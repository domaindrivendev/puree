module Pure
  module EventBus

    class Listener

      module ClassMethods
        attr_reader :event_name

        def subscribes_to(event_name)
          @event_name = event_name
        end

        def on_notified(&block)
          on_notified_blocks << block
        end

        def on_notified_blocks
          @on_notified_blocks ||= []
        end
      end

      def self.inherited(klass)
        klass.extend(ClassMethods)
      end

      def event_name
        self.class.event_name
      end

      def notify(event)
        self.class.on_notified_blocks.each do |block|
          instance_exec(event, &block)
        end
      end

    end

  end
end