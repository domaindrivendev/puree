module Puree
	module Persistence
		class EventStoreRepository

			def initialize(aggregate_root_factory, event_store, event_bus)
				@factory = aggregate_root_factory
				@event_store = event_store
				@event_bus = event_bus
			end

			def add(aggregate_root)
				@event_store.register_aggregate(aggregate_root.id_token)
				@event_store.add_aggregate_events(aggregate_root.id_token, aggregate_root.pending_events)

				publish_events(aggregate_root)
			end

			def find(identifier)
				class_name = @factory.class.aggregate_root_class.name
				id_token = "#{class_name}#{identifier}"
				events = @event_store.get_aggregate_events(id_token)

        aggregate_root = @factory.recreate(events.first)
        aggregate_root.replay_events(events.drop(1))
        aggregate_root
			end

			def update(aggregate_root)
				@event_store.add_aggregate_events(aggregate_root.id_token, aggregate_root.pending_events)

				publish_events(aggregate_root)
			end

			private

			def publish_events(aggregate_root)
				# Add aggregate_root identifier to the event.args
				identifier_name = aggregate_root.class.identifier_name
				identifier_value = aggregate_root.send(identifier_name)

				aggregate_root.pending_events.each do |event|
					event.args[identifier_name] = identifier_value
					@event_bus.publish(event)
				end
			end
		end
	end
end