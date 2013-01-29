require 'puree'

Puree.configure do |config|
	config.message_bus = Puree::Messaging::SyncMessageBus.new
	config.event_store = Puree::Persistence::MemoryEventStore.new
	config.id_generator = Puree::Persistence::MemoryIdGenerator.new
end

require 'rspec-spies'