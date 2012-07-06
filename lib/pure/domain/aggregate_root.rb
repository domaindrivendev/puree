require 'pure'
require 'pure/domain/event'

module Pure
	module Domain
		class AggregateRoot
			
			attr_reader :id

			def self.create(attributes={})
				aggregate_root = new(attributes)

        # TODO: Investigate id gen concurrency
				id_gen = Pure.config.id_generator
				id = id_gen.next_id(aggregate_root.class.name)
				aggregate_root.instance_variable_set(:@id, id)

        name = aggregate_root.class.name.split('::').last
        underscored_name = name.gsub(/(.)([A-Z])/, '\1_\2').downcase
        event_type = "#{underscored_name}_created".to_sym
        event_list = [ Pure::Domain::Event.new(id, event_type, attributes) ]
				aggregate_root.instance_variable_set(:@event_list, event_list)

				return aggregate_root
			end
		end
	end
end