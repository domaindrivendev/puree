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

class FakeEventBus
  attr_reader :publications

  def initialize
    @publications = []
  end

  def publish(event)
    @publications << event
  end
end