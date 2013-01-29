require 'singleton'

module Puree
		
	class Configuration
		include Singleton

		attr_writer :message_bus, :event_store, :id_generator

		def message_bus
      if @message_bus.nil?
        raise 'Puree::Rails.config.message_bus has not been configured'
      end
      @message_bus
		end

    def event_store
      if @event_store.nil?
        raise 'Puree::Rails.config.event_store has not been configured'
      end
      @event_store
    end

    def id_generator
      if @id_generator.nil?
        raise 'Puree::Rails.config.id_generator has not been configured'
      end
      @id_generator
    end
	end

end