require 'puree'

Puree.configure do |config|
	config.id_generator = Puree::Persistence::MemoryIdGenerator.new
	config.event_store = Puree::Persistence::MemoryEventStore.new
	config.event_bus = Puree::EventBus::MemoryEventBus.new
end

require 'rspec-spies'