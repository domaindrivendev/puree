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

      def initialize(aggregate_root_class)
        @aggregate_root_class = aggregate_root_class
      end

      def signal_event(name, args={})
        id = args[@aggregate_root_class.identifier_name]
        id_hash = "#{@aggregate_root_class.name}#{id}"
        event = Puree::Domain::Event.new(id_hash, name, args)
        
        aggregate_root = apply_event(event)
        aggregate_root.send(:event_stream).add(event)

        aggregate_root
      end

      def recreate(creation_event)
        apply_event(creation_event)
      end
      
      private

      def apply_event(event)
        apply_event_blocks = self.class.apply_event_blocks
        if apply_event_blocks[event.name].nil?
          raise "Failed to apply event - no apply_event block found for #{event.name}"
        end

        aggregate_root = instance_exec(event, &apply_event_blocks[event.name])

        aggregate_root
      end

		end

	end
end