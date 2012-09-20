require 'singleton'
require 'puree/version'
require 'puree/domain/event'
require 'puree/domain/entity'
require 'puree/domain/entity_collection'
require 'puree/domain/aggregate_root'
require 'puree/domain/aggregate_root_factory'
require 'puree/persistence/event_store_repository'
require 'puree/persistence/memory_event_store'
require 'puree/event_bus/subscriber'
require 'puree/event_bus/memory_event_bus'

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

  end

end