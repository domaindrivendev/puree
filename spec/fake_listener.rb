require 'pure/event_bus/listener'

class FakeListener < Pure::EventBus::Listener
  subscribes_to :fake_event

  attr_accessor :times_executed

  on_notified do |event|
    @times_executed += 1
  end

end