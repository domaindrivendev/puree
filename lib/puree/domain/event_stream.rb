module Puree
	module Domain

		class EventStream
			attr_reader :aggregate_root_id_hash

			def initialize(aggregate_root_id_hash)
				@aggregate_root_id_hash = aggregate_root_id_hash
				@events = []
			end

			def add(event)
				@events << event
			end

			def all
				@events.clone
			end
		end

	end
end