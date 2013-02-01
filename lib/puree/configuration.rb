require 'singleton'

module Puree
		
	class Configuration
		include Singleton

		attr_writer :event_store, :message_bus

    def event_store
      if @event_store.nil?
        raise 'Puree::Rails.config.event_store has not been configured'
      end
      @event_store
    end

    def message_bus
      if @message_bus.nil?
        raise 'Puree::Rails.config.message_bus has not been configured'
      end
      @message_bus
    end
	end

end