module Puree
	module Domain

		class EntityCollection
			include Enumerable

			def initialize(aggregate_root)
				@aggregate_root = aggregate_root
				@entities = []
			end

			def each
				@entities.each { |entity| yield(entity) }
			end

			def << (entity)
				@entities << entity
				entity.instance_variable_set(:@aggregate_root, @aggregate_root)
			end

			def find_by_id(entity_id)
				return @entities.find { |entity| entity.id == entity_id }
			end

			def delete(entity)
				@entities.delete(entity)
			end

			def to_array
				@entities
			end

		end

	end
end