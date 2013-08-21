module Puree
  
  class Repository

    def self.for(klass, id_selector, event_store, event_bus)
      new(klass, id_selector, event_store, event_bus)
    end

    def initialize(klass, id_selector, event_store, event_bus)
      @klass = klass
      @id_selector = id_selector
      @event_store = event_store
      @event_bus = event_bus
    end

    def add(source)
      stream_name = "#{@klass.name}_#{@id_selector.call(source)}"

      @event_store.post(stream_name, source.pending_events)
    end

    def find(source_id)
      stream_name = "#{@klass.name}_#{source_id}"
      stream = @event_store.get(stream_name)

      source = @klass.allocate
      stream.each { |event| source.replay(event) }
      return source
    end
  end

end