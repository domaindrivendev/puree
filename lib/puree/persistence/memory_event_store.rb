module Puree
	module Persistence

		class MemoryEventStore

			def initialize
				@events = {}
			end

			def register_aggregate_root(id_hash)
				if @events.has_key?(id_hash)
					raise 'TODO: Provided id_hash must be unique'
				end
				@events[id_hash] = []
			end

			def add_events(aggregate_root_id_hash, event_list)
				unless @events.has_key?(aggregate_root_id_hash)
					raise "Aggregate root with id hash #{aggregate_root_id_hash} does not exist"
				end
				@events[aggregate_root_id_hash].concat(event_list)
			end

			def get_events(aggregate_root_id_hash)
				unless @events.has_key?(aggregate_root_id_hash)
					raise "Aggregate root with id hash #{aggregate_root_id_hash} does not exist"
				end
				@events[aggregate_root_id_hash]		
			end

			def reset
				@events.clear
			end
		end

	end
end