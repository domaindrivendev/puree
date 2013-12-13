class FakeEventStore

  def initialize
    @streams = {}
  end

  def create_stream(stream_name, events)
    @streams[stream_name] = []
    @streams[stream_name].concat(events)
  end

  def get_events_for(stream_name)
    @streams[stream_name] || []
  end

  def append_events_to(stream_name, events)
    @streams[stream_name].concat(events)
  end
end

class FakeEventDispatcher
  attr_reader :dispatched_events

  def initialize
    @dispatched_events = []
  end

  def dispatch(event)
    @dispatched_events << event
  end
end