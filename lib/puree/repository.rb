module Puree
  
  class Repository

    def self.for(klass, event_store, event_dispatcher=nil)
      new(klass, event_store, event_dispatcher)
    end

    def initialize(klass, event_store, event_dispatcher=nil)
      @klass = klass
      @event_store = event_store
      @event_dispatcher = event_dispatcher
    end

    def add(source)
      return if source.pending_events.empty?

      @event_store.create_stream(stream_name_for(source), source.pending_events)

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

      @event_store.append_events_to(stream_name_for(source), source.pending_events)

      unless @event_dispatcher.nil?
        source.pending_events.each { |event| @event_dispatcher.dipatch(event) }
      end
    end

    private

    def stream_name_for(source)
      source_id = source.send(@klass.identifier_name)
      stream_name = "#{@klass.name}_#{source_id}"
    end
  end

end