module Puree
	module Persistence

		class MemoryIdGenerator
			def initialize
				@counters = {}
			end

			def next(scope)
				unless @counters.has_key?(scope)
					@counters[scope] = 0
				end
				@counters[scope] += 1
				@counters[scope]
			end

			def reset
				@counters = {}
			end
		end

	end
end