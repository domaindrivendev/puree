module Puree
	module Domain

		class AggregateRoot < Entity
      
      def aggregate_root
        self
      end

      def replay_events(events)
        events.each do |event|
          entity = find_within(self, event.source_id_hash)
          if entity.nil?
            raise "Failed to replay event - no entity found with id_hash #{event.source_id_hash}"
          end

          entity.send(:apply_event, event)
        end
      end

      def pending_events
        event_stream.all
      end 

      private

      def find_within(entity, id_hash)
        # TODO: Optimize search algorithm
        if entity.id_hash == id_hash
          return entity
        else
          get_sub_entities(entity).each do |sub_entity|
            entity = find_within(sub_entity, id_hash)
            return entity unless entity.nil?
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

      def event_stream
        @event_stream ||= EventStream.new(id_hash)
      end

		end
    
	end
end