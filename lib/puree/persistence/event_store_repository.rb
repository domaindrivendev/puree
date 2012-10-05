module Puree
	module Persistence
		class EventStoreRepository

			def initialize(aggregate_root_factory, event_store, event_bus)
				@factory = aggregate_root_factory
				@event_store = event_store
				@event_bus = event_bus
			end

			def save(aggregate_root)
				event_list = aggregate_root.instance_variable_get(:@event_list)

				event_list.each do |event|
					# TODO: Support for concurrency
          @event_store.save(event)
				end

        event_list.each do |event|
          @event_bus.publish(event)
        end
      end

			def get_by_id(aggregate_root_id)
				events = @event_store.get_aggregate_events(@factory.aggregate_root_class.name, aggregate_root_id)
        
        aggregate_root = @factory.recreate(events.first)
        aggregate_root.replay_events(events.drop(1))
        aggregate_root
			end

		end
	end
end