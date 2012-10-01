module Puree
	module Domain

		class AggregateRoot < Entity
			def initialize(id)
				super(id)
        @aggregate_root = self
        @event_list = []
			end

      def replay_events(events)
        events.each do |event|
          entity = find_entity(self, event.source_id, event.source_class_name)
          if entity.nil?
            attributes = "aggregate_root_id: #{event.aggregate_root_id}, id: #{event.source_id}, class_name: #{event.source_class_name}" 
            raise "Failed to replay event - no entity found with #{attributes}"
          end

          entity.send(:apply_event, event)
        end
      end

      def find_entity(root, id, class_name)
        # TODO: Optimize search algorithm
        if root.id == id and root.class.name == class_name
          return root
        else
          get_sub_entities(root).each do |sub_entity|
            entity = find_entity(sub_entity, id, class_name)
            return entity unless entity.nil?
          end
        end
        nil
      end

      def get_sub_entities(parent)
        sub_entities = parent.instance_variable_get(:@entities).values
        parent.instance_variable_get(:@entity_collections).values.each do |collection|
          sub_entities.concat(collection.to_array)
        end
        sub_entities
      end
		end
    
	end
end