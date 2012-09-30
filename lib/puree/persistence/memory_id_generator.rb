	module Puree
		module Persistence

			class MemoryIdGenerator

				def initialize
					@id_counters = {}
				end

				def next_id(factory_class_name)
					if @id_counters[factory_class_name].nil?
						@id_counters[factory_class_name] = 0
					end

					@id_counters[factory_class_name] += 1
				end

				def reset
					@id_counters.clear
				end

			end

		end
	end