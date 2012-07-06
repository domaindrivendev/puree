module Pure
  module Domain
    class Event

      attr_reader :aggregate_id, :event_type, :attributes

      def initialize(aggregate_id, event_type, attributes={})
        @aggregate_id = aggregate_id
        @event_type = event_type
        @attributes = attributes
      end

    end
  end
end