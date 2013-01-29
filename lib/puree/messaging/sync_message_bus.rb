require 'puree/messaging/command_handler'
require 'puree/messaging/event_handler'

module Puree
  module Messaging

    class SyncMessageBus

    	def initialize
    		@command_handlers = []
    		@event_handlers = []
    	end

      def register_command_handler(command_handler)
        @command_handlers << command_handler
      end

      def register_event_handler(event_handler)
        @event_handlers << event_handler
      end

      def send_command(name, args={})
      	@command_handlers.each do |handler|
      		if handler.has_block_for?(name)
      			handler.execute(name, args)
      		end
      	end
      end

      def publish_event(name, args={})
      	@event_handlers.each do |handler|
      		if handler.has_block_for?(name)
      			handler.notify(name, args)
      		end
      	end
      end

    end

  end
end