module Puree
	module Persistence

		class MemoryEventStore

			def initialize
				@events = {}
			end

			def register_aggregate(identity_token)
				if @events.has_key?(identity_token)
					raise 'Provided identity_token must be unique'
				end
				@events[identity_token] = []
			end

			def add_aggregate_events(identity_token, event_list)
				unless @events.has_key?(identity_token)
					raise "Aggregate with identity token #{identity_token} does not exist"
				end
				@events[identity_token].concat(event_list)
			end

			def get_aggregate_events(identity_token)
				unless @events.has_key?(identity_token)
					raise "Aggregate with identity token #{identity_token} does not exist"
				end
				@events[identity_token]		
			end

			def reset
				@events.clear
			end
		end

	end
end