module Puree
  module Domain
    class Event

      attr_reader :root_id, :name, :args

      def initialize(root_id, name, args={})
        @root_id = root_id
        @name = name
        @args = args
      end

    end
  end
end