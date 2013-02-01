module Puree
	module Persistence
		class EventStoreRepository

			def initialize(aggregate_factory, event_store, message_bus)
				@factory = aggregate_factory
				@event_store = event_store
				@message_bus = message_bus
			end

			def add(aggregate_root)
				@event_store.register_aggregate(aggregate_root.identity_token)
				@event_store.add_aggregate_events(aggregate_root.identity_token, aggregate_root.pending_events)

				publish_events(aggregate_root)
			end

			def find(identifier)
				class_name = @factory.class.name[0...-7]

				identity_token = "#{class_name}_#{identifier}"
				events = @event_store.get_aggregate_events(identity_token)

        aggregate_root = @factory.recreate(events.first)
        aggregate_root.replay_events(events.drop(1))
        aggregate_root
			end

			def update(aggregate_root)
				@event_store.add_aggregate_events(aggregate_root.identity_token, aggregate_root.pending_events)

				publish_events(aggregate_root)
			end

			private

			def publish_events(aggregate_root)
				aggregate_root.pending_events.each do |event|
					@message_bus.publish_event(event.name, event.args)
				end
			end
		end
	end
end