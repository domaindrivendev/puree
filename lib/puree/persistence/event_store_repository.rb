module Puree
	module Persistence
		class EventStoreRepository

			def initialize(aggregate_root_factory, event_store, event_bus)
				@factory = aggregate_root_factory
				@event_store = event_store
				@event_bus = event_bus
			end

			def add(aggregate_root)
				@event_store.register_aggregate_root(aggregate_root.id_hash)
				@event_store.add_events(aggregate_root.id_hash, aggregate_root.pending_events)

				publish_events(aggregate_root.pending_events)
			end

			def find(identifier)
				class_name = @factory.class.aggregate_root_class.name
				id_hash = "#{class_name}#{identifier}"
				events = @event_store.get_events(id_hash)

        aggregate_root = @factory.recreate(events.first)
        aggregate_root.replay_events(events.drop(1))
        aggregate_root
			end

			def update(aggregate_root)
				@event_store.add_events(aggregate_root.id_hash, aggregate_root.pending_events)

				publish_events(aggregate_root.pending_events)
			end

			private

			def publish_events(events)
				events.each { |event| @event_bus.publish(event) }
			end
		end
	end
end