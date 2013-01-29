require 'singleton'
require 'puree/version'
require 'puree/domain/event'
require 'puree/domain/entity'
require 'puree/domain/entity_collection'
require 'puree/domain/aggregate_root'
require 'puree/domain/aggregate_factory'
require 'puree/messaging/sync_message_bus'
require 'puree/persistence/event_store_repository'
require 'puree/persistence/memory_event_store'
require 'puree/persistence/memory_id_generator'
require 'puree/conventions'
require 'puree/commanding'
require 'puree/configuration'

module Puree
	def self.config
		Configuration.instance
	end

	def self.configure
		yield(config)
	end
end