module Puree
  module Domain
    
    class Event
      attr_reader :source_identity_token, :name, :args

      def initialize(source_identity_token, name, args={})
        @source_identity_token = source_identity_token
        @name = name
        @args = args
      end
    end

  end
end