module Puree
	module Persistence

		class MemoryEventStore

			def initialize
				@events = {}
			end

			def register_aggregate(id_token)
				if @events.has_key?(id_token)
					raise 'TODO: Provided id_token must be unique'
				end
				@events[id_token] = []
			end

			def add_aggregate_events(id_token, event_list)
				unless @events.has_key?(id_token)
					raise "Aggregate with identity token #{id_token} does not exist"
				end
				@events[id_token].concat(event_list)
			end

			def get_aggregate_events(id_token)
				unless @events.has_key?(id_token)
					raise "Aggregate with identity token #{id_token} does not exist"
				end
				@events[id_token]		
			end

			def reset
				@events.clear
			end
		end

	end
end