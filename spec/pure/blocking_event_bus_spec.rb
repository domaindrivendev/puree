require 'spec_helper'
require 'fake_listener'
require 'pure/domain/event'
require 'pure/event_bus/blocking_event_bus'

describe 'Blocking event bus' do
  let(:event_bus) { Pure::EventBus::BlockingEventBus.new }

  context 'with one or more listeners for an event' do
    let(:listener1) { FakeListener.new }
    let(:listener2) { FakeListener.new }

    before do
      event_bus.register_listener(listener1)
      event_bus.register_listener(listener2)
    end

    context 'when the event is published' do
      before do
        listener1.times_executed = 0
        listener2.times_executed = 0
        event_bus.publish(Pure::Domain::Event.new(1, :fake_event, { some_attribute: 'foobar' }))
      end

      it 'should execute all listeners for the event before returning control' do
        listener1.times_executed.should == 1
        listener2.times_executed.should == 1
      end
    end
  end
end