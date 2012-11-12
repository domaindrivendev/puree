require 'singleton'
require 'puree/version'
require 'puree/domain/event'
require 'puree/domain/entity'
require 'puree/domain/entity_collection'
require 'puree/domain/aggregate_root'
require 'puree/domain/aggregate_root_factory'
require 'puree/persistence/event_store_repository'
require 'puree/persistence/memory_event_store'
require 'puree/event_bus/observer'
require 'puree/event_bus/memory_event_bus'
require 'puree/conventions'
require 'puree/commanding'
require 'puree/configuration'

module Puree
	def self.config
		Configuration.instance
	end
end