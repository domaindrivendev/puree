module Puree
  module Domain
    
    class Event
      attr_reader :source_id_token, :name, :args

      def initialize(source_id_token, name, args={})
        @source_id_token = source_id_token
        @name = name
        @args = args
      end
    end

  end
end