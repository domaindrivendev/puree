require 'pure/domain/entity'
require 'pure/domain/event'

module Pure
	module Domain
		class AggregateRoot < Entity

      def self.create(id, attributes)
        instance = new(id, attributes)

        # Inject event_list, including initial 'creation' event
        event_list = [ Pure::Domain::Event.new(id, created_event_name, attributes) ]
        instance.instance_variable_set(:@event_list, event_list)

        instance
      end

      def self.recreate(previous_events)
        if previous_events.nil? or previous_events.length == 0
          raise "Can't recreate without any previous events"
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

      private

      def self.created_event_name
        name = self.name.split('::').last
        underscored_name = name.gsub(/(.)([A-Z])/, '\1_\2').downcase
        "#{underscored_name}_created".to_sym
      end

		end
	end
end