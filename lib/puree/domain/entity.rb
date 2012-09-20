module Puree
  module Domain

    class Entity

      module ClassMethods
        def apply_event(name, &block)
          apply_event_blocks[name] = block
        end

        def has_a(name)
          one_to_one_associations << name.to_s  
        end

        def has_many(name)
          one_to_many_associations << name.to_s  
        end

        def apply_event_blocks
          @apply_event_block ||= {}
        end

        def one_to_one_associations
          @one_to_one_associations ||= []
        end

        def one_to_many_associations
          @one_to_many_associations ||= []
        end    
      end

      def self.inherited(klass)
        klass.extend(ClassMethods)
      end

      attr_reader :aggregate_root_id, :id, :parent

      def initialize(id, parent=nil)
        @id = id
        @parent = parent

        if parent.nil? # i.e. this is the aggregate root
          @aggregate_root_id = @id
          @event_list = []
        else
          @aggregate_root_id = parent.aggregate_root_id
          @event_list = parent.instance_variable_get(:@event_list)
        end

        @entities ||= {}
        @entity_collections ||= {}
      end

      def signal_event(name, attributes={})
        event = Puree::Domain::Event.new(aggregate_root_id, id, self.class.name, name, attributes)
        apply_event(event)

        @event_list << event
      end

      def pending_events
        @event_list.clone
      end

      def method_missing(method, *args, &block)
        method_name = method.to_s
        one_to_one_associations = self.class.one_to_one_associations
        one_to_many_associations = self.class.one_to_many_associations

        # association accessors
        if one_to_one_associations.include?(method_name) and @entities.has_key?(method_name)
          return @entities[method_name]
        elsif one_to_many_associations.include?(method_name)
          return @entity_collections[method_name] ||= []
        end

        # one to one asssociation setters
        if method_name.start_with?('set_')
          association = method_name[4..-1]
          if one_to_one_associations.include?(association)
            return @entities[association] = args[0]
          end
        end

        super.method_missing(method, args, block)
      end

      private

      def apply_event(event)
        apply_event_blocks = self.class.apply_event_blocks
        if apply_event_blocks[event.name].nil?
          raise "Failed to apply event - no apply_event block found for #{event.name}"
        end
        instance_exec(event, &apply_event_blocks[event.name])
      end

    end
  end
end