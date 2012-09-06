require 'spec_helper'
require 'puree/event_bus/blocking_event_bus'
require 'puree/domain/event'

describe 'a blocking event bus' do
  $handlers_executed = 0
  let(:event_bus) { Puree::EventBus::BlockingEventBus.new }

  context 'with one or more subscribers registered for an event' do
    class Subscriber1 < Puree::EventBus::Subscriber
      on_event :some_event do |event|
        $handlers_executed += 1
      end
    end

    class Subscriber2 < Puree::EventBus::Subscriber
      on_event :some_event do |event|
        $handlers_executed += 1
      end
    end

    before do
      event_bus.register(Subscriber1.new)
      event_bus.register(Subscriber2.new)
    end

    context 'when that event is published' do
      before do
        $handlers_executed = 0
        event_bus.publish(Puree::Domain::Event.new(1, :some_event, { some_attribute: 'foobar' }))
      end

      it 'should execute all registered handlers for that event before returning control' do
        $handlers_executed.should == 2
      end
    end
  end
end