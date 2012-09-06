module Puree
  module Domain
    class Entity

      module ClassMethods
        def apply_event(name, &block)
          apply_event_blocks[name] = block
        end

        def apply_event_blocks
          @apply_event_block ||= {}
        end
      end

      def self.inherited(klass)
        klass.extend(ClassMethods)
      end

      attr_reader :id

      def signal_event(name, attributes={})
        exec_apply_event_block(name, attributes)

        @event_list << Puree::Domain::Event.new(id, name, attributes)
      end

      def pending_events
        @event_list.clone
      end

      def replay_events(previous_events)
        previous_events.each do |event|
          exec_apply_event_block(event.name, event.attributes)
        end
      end

      private

      def exec_apply_event_block(event_name, attributes)
        apply_event_blocks = self.class.apply_event_blocks
        if apply_event_blocks[event_name].nil?
          raise "Failed to apply event - no apply_event block registered for #{event_name}"
        end
        instance_exec(attributes, &apply_event_blocks[event_name])
      end

    end
  end
end