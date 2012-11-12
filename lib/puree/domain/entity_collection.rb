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

			def delete(entity)
				@entities.delete(entity)
			end

		end

	end
end