module Pure
	module Repositories
		class EventStoreRepository

			def self.for_aggregate_root(aggregate_root_klass)
				new(aggregate_root_klass)
			end

			def initialize(aggregate_root_klass)
				@aggregate_root_klass = aggregate_root_klass
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

      def get_by_id(id)
        previous_events = Pure.config.event_store.get_by_aggregate_root_id(id)

        @aggregate_root_klass.recreate(previous_events)
      end
		end
	end
end