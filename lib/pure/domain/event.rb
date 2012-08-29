module Pure
  module Domain
    class Event

      attr_reader :aggregate_id, :name, :attributes

      def initialize(aggregate_id, name, attributes={})
        @aggregate_id = aggregate_id
        @name = name
        @attributes = attributes
      end

    end
  end
end