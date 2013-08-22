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
      return if source.pending_events.empty?

      stream_name = "#{@klass.name}_#{@id_selector.call(source)}"
      
      # TODO: Need a transaction here 
      @event_store.append_to_stream(stream_name, source.pending_events)
      source.pending_events.each { |event| @event_bus.publish(event) }
    end

    def find_by(source_id)
      stream_name = "#{@klass.name}_#{source_id}"
      stream = @event_store.get_stream(stream_name)

      source = @klass.allocate
      stream.each { |event| source.replay(event) }
      return source
    end

    def update(source)
      return if source.pending_events.empty?

      stream_name = "#{@klass.name}_#{@id_selector.call(source)}"
      
      # TODO: Need a transaction here 
      @event_store.append_to_stream(stream_name, source.pending_events)
      source.pending_events.each { |event| @event_bus.publish(event) }
    end
  end

end