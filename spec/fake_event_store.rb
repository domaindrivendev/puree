class FakeEventStore

  def initialize
    @streams = {}
  end

  def post(stream_name, events)
    @streams[stream_name] ||= []
    @streams[stream_name].concat(events)
  end

  def get(stream_name)
    @streams[stream_name] || []
  end

end