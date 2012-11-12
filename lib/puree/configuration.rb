require 'singleton'

module Puree
		
	class Configuration
		include Singleton

		attr_writer :event_store, :event_bus

		def event_store
      if @event_store.nil?
        raise 'Puree::Rails.config.event_store has not been configured'
      end
      @event_store
		end

		def event_bus
      if @event_bus.nil?
        raise 'Puree::Rails.config.event_bus has not been configured'
      end
      @event_bus
		end
	end

end