module Puree
  
  class Repository

    def self.for(klass, id_selector, event_store, event_dispatcher=nil)
      new(klass, id_selector, event_store, event_dispatcher)
    end

    def initialize(klass, id_selector, event_store, event_dispatcher=nil)
      @klass = klass
      @id_selector = id_selector
      @event_store = event_store
      @event_dispatcher = event_dispatcher
    end

    def add(source)
      return if source.pending_events.empty?

      stream_name = "#{@klass.name}_#{@id_selector.call(source)}"
      
      # TODO: Need a transaction here 
      @event_store.create_stream(stream_name, source.pending_events)

      unless @event_dispatcher.nil?
        source.pending_events.each { |event| @event_dispatcher.dispatch(event) }
      end
    end

    def find_by(source_id)
      stream_name = "#{@klass.name}_#{source_id}"
      stream = @event_store.get_events_for(stream_name)

      source = @klass.allocate
      stream.each { |event| source.replay(event) }
      return source
    end

    def update(source)
      return if source.pending_events.empty?

      stream_name = "#{@klass.name}_#{@id_selector.call(source)}"
      
      # TODO: Need a transaction here 
      @event_store.append_events_to(stream_name, source.pending_events)

      unless @event_dispatcher.nil?
        source.pending_events.each { |event| @event_dispatcher.dipatch(event) }
      end
    end
  end

end