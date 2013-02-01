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
require 'puree/configuration'
require 'puree/conventions'
require 'puree/domain_facade'
require 'puree/commanding'

module Puree
	def self.config
		Configuration.instance
	end

	def self.configure
		yield(config)
	end
end