module Puree
	module Domain

		class EntityCollection
			include Enumerable

			def initialize(event_list)
				@event_list = event_list
				@entities = []
			end

			def each
				@entities.each { |entity| yield(entity) }
			end

			def << (entity)
				@entities << entity
				entity.instance_variable_set(:@event_list, @event_list)
			end

			def [](index)
				@entities[index]
			end
		end

	end
end