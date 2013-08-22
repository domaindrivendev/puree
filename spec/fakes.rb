class FakeEventStore

  def initialize
    @streams = {}
  end

  def add_events(stream_name, events)
    @streams[stream_name] ||= []
    @streams[stream_name].concat(events)
  end

  def get_events(stream_name)
    @streams[stream_name] || []
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