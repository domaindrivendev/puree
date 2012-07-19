require 'pure'
require 'pure/domain/event'

module Pure
	module Domain
		class AggregateRoot

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

      def self.create(id, attributes)
        instance = new(id, attributes)

        # Inject event_list, including initial 'creation' event
        event_list = [ Pure::Domain::Event.new(id, created_event_name, attributes) ]
        instance.instance_variable_set(:@event_list, event_list)

        instance
      end

      def self.created_event_name
        name = self.name.split('::').last
        underscored_name = name.gsub(/(.)([A-Z])/, '\1_\2').downcase
        "#{underscored_name}_created".to_sym
      end

      def self.recreate(previous_events)
        if previous_events.nil? or previous_events.length == 0
          raise "Can't' recreate without any previous events"
        end

        created_event = previous_events.first
        if created_event.name != created_event_name
          raise "Can't recreate when initial event is not #{created_event_name}"
        end

        instance = create(created_event.aggregate_root_id, created_event.attributes)
        instance.replay_events(previous_events.drop(1))
        instance.instance_variable_set(:@event_list, [])

        instance
      end

      attr_reader :id

      def signal_event(name, attributes)
        apply_event_blocks = self.class.apply_event_blocks
        if apply_event_blocks[name].nil?
          raise "Failed to apply event - no apply_event block registered for #{name}"
        end
        instance_exec(&apply_event_blocks[name])

        @event_list << Pure::Domain::Event.new(id, name, attributes)
      end

      def pending_events
        @event_list.clone
      end

      def replay_events(previous_events)
      end

		end
	end
end