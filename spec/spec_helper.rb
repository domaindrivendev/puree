require 'puree'

Puree.config.event_store = Puree::Persistence::MemoryEventStore.new
Puree.config.event_bus = Puree::EventBus::MemoryEventBus.new

require 'rspec-spies'