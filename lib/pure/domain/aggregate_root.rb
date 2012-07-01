require 'pure'
require 'pure/domain/aggregate_root_created_event'

module Pure
	module Domain
		class AggregateRoot
			
			attr_reader :id

			def self.create(attributes={})
				aggregate_root = new(attributes)

				# TODO: Generate id
				generator = Pure.config.id_generator
				id = generator.id_for_entity(aggregate_root.class)

				aggregate_root.instance_variable_set(:@id, id)

				event_list = []
				event_list << AggregateRootCreatedEvent.new(aggregate_root.class.name, attributes)
				aggregate_root.instance_variable_set(:@event_list, event_list)

				return aggregate_root
			end
		end
	end
end