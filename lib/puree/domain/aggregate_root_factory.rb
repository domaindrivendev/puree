module Puree
	module Domain

		class AggregateRootFactory

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

      def initialize(id_generator)
        @id_generator = id_generator
      end

      def signal_event(name, args={})
        event = Puree::Domain::Event.new(args[:id], nil, self.class.name, name, args)
        aggregate_root = apply_event(event)

        # Inject the creation event
        event_list = aggregate_root.instance_variable_get(:@event_list)
        event_list << event

        aggregate_root
      end

      def recreate(creation_event)
        if self.class.name != creation_event.source_class_name
          raise "Failed to recreate aggregate root - creation event was sourced from a different factory: #{creation_event.source_class_name}"
        end

        apply_event(creation_event)
      end

      def next_id
        @id_generator.next_id(self.class.name)
      end

      private

      def apply_event(event)
        apply_event_blocks = self.class.apply_event_blocks
        if apply_event_blocks[event.name].nil?
          raise "Failed to apply event - no apply_event block found for #{event.name}"
        end

        instance_exec(event, &apply_event_blocks[event.name])
      end

		end

	end
end