require 'singleton'
require "pure/version"

module Pure

  def self.config
    Configuration.instance
  end

  class Configuration
  	include Singleton

  	attr_accessor :id_generator, :event_store

  	def id_generator
      if @id_generator.nil?
        raise 'Pure.config.id_generator has not been configured'
      end
      @id_generator
    end

    def event_store
      if @event_store.nil?
        raise 'Pure.config.event_store has not been configured'
      end
      @event_store
    end

  end

end