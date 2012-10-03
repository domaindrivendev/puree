module Puree
  module Domain
    class Event

      attr_reader :aggregate_root_class_name, :aggregate_root_id, :source_class_name, :source_id, :name, :args

      def initialize(aggregate_root_class_name, aggregate_root_id, source_class_name, source_id, name, args={})
        @aggregate_root_class_name = aggregate_root_class_name
        @aggregate_root_id = aggregate_root_id
        @source_class_name = source_class_name
        @source_id = source_id
        @name = name
        @args = args
      end

    end
  end
end