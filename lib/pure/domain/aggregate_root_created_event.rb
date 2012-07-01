module Pure
	module Domain
		class AggregateRootCreatedEvent
			attr_reader :class_name, :attributes

			def initialize(class_name, attributes)
				@class_name = class_name
				@attributes = attributes
			end
		end
	end
end