module Pure
	module Repositories
		class EventStoreRepository

			def self.for_aggregate_root(aggregate_root_class)
				new(aggregate_root_class)
			end

			def initialize(aggregate_root_class)
				@aggregate_root_class = aggregate_root_class
			end

			def save(aggregate_root)
				event_list = aggregate_root.instance_variable_get(:@event_list)

				event_store = Pure.config.event_store
				event_list.each do |event|
					# TODO: Support for concurrency
					event_store.save(event)
				end

				# TODO: Dispatch events on event bus
			end
		end
	end
end