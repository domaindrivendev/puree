module Puree
	module Domain

		class AggregateRoot < Entity
      
      def replay_events(events)
        events.each do |event|
          entity = find_entity(self, event.source_id_token)
          if entity.nil?
            raise "Failed to replay event - no entity found with identity token #{event.source_id_token}"
          end

          entity.send(:apply_event, event)
        end
      end

      def pending_events
        event_list.clone
      end

      private

      def aggregate_root
        self
      end

      def event_list
        @event_list ||= []
      end

      def find_entity(parent, id_token)
        # TODO: Optimize search algorithm
        if parent.id_token == id_token
          return parent
        else
          get_sub_entities(parent).each do |sub_entity|
            parent = find_entity(sub_entity, id_token)
            return parent unless parent.nil?
          end
        end
        nil
      end

      def get_sub_entities(entity)
        sub_entities = entity.send(:entities).values
        entity.send(:entity_collections).values.each do |collection|
          sub_entities.concat(collection.entries)
        end
        sub_entities
      end

		end
    
	end
end