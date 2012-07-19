module Pure
  module Domain
    class Event

      attr_reader :aggregate_root_id, :name, :attributes

      def initialize(aggregate_root_id, name, attributes={})
        @aggregate_root_id = aggregate_root_id
        @name = name
        @attributes = attributes
      end

    end
  end
end