module Puree
	module Domain

		class AggregateRootFactory

			module ClassMethods
        attr_reader :aggregate_root_class

        def for_aggregate_root(klass)
          @aggregate_root_class = klass
        end

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

      def signal_event(name, args={})
        event = Puree::Domain::Event.new(self.class.name, name, args)
        
        aggregate_root = apply_event(event)
        aggregate_root.send(:event_list) << event

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