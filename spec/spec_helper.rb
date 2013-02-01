require 'puree'

Puree.configure do |config|
	config.message_bus = Puree::Messaging::SyncMessageBus.new
	config.event_store = Puree::Persistence::MemoryEventStore.new
end

require 'rspec-spies'