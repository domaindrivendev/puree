module Puree
  module Domain
    
    class Event
      attr_reader :source_id_hash, :name, :args

      def initialize(source_id_hash, name, args={})
        @source_id_hash = source_id_hash
        @name = name
        @args = args
      end
    end

  end
end