require 'singleton'
require 'puree/version'
require 'puree/domain/aggregate_root'
require 'puree/event_bus/blocking_event_bus'

module Puree

  def self.config
    Configuration.instance
  end

  class Configuration
  	include Singleton

  	attr_accessor :id_generator, :event_store, :event_bus

  	def id_generator
      if @id_generator.nil?
        raise 'Puree.config.id_generator has not been configured'
      end
      @id_generator
    end

    def event_store
      if @event_store.nil?
        raise 'Puree.config.event_store has not been configured'
      end
      @event_store
    end

    def event_bus
      @event_bus ||= Puree::EventBus::BlockingEventBus.new
    end

  end

end