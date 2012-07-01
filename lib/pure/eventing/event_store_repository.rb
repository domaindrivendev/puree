module Pure
	module Eventing
		class EventStoreRepository

			def self.for_aggregate_root(aggregate_root_class)
				new(aggregate_root_class)
			end

			def initialize(aggregate_root_class)
				@aggregate_root_class = aggregate_root_class
			end

			def save(aggregate_root)
			end
		end
	end
end