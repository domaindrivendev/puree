module Puree
  module Domain
    class Event

      attr_reader :aggregate_root_id, :source_id, :source_class_name, :name, :attributes

      def initialize(aggregate_root_id, source_id, source_class_name, name, attributes={})
        @aggregate_root_id = aggregate_root_id
        @source_id = source_id
        @source_class_name = source_class_name
        @name = name
        @attributes = attributes
      end

    end
  end
end