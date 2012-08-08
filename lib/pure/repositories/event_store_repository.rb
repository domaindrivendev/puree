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

				event_list.each do |event|
					# TODO: Support for concurrency
          Pure.config.event_store.save(event)
				end

        event_list.each do |event|
          Pure.config.event_bus.publish(event)
        end
			end
		end
	end
end