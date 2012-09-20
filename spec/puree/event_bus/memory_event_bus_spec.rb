require 'spec_helper'

describe 'A memory events bus instance' do
	let(:event_bus) { Puree::EventBus::MemoryEventBus.new }

	context 'with registered subscribers to an event' do
		before(:each) do
			class TestSubscriber < Puree::EventBus::Subscriber
				def events_received
					@events_received ||= []
				end

				on_event :test_event1 do |event|
					events_received << event
				end
			end

			@subscriber1 = TestSubscriber.new
			@subscriber2 = TestSubscriber.new

			event_bus.register(@subscriber1)
			event_bus.register(@subscriber2)
		end

		context 'when that event is published' do
			before(:each) do
				@test_event = Puree::Domain::Event.new(123, 123, 'TestAggRoot', :test_event1, { value: 10 })
				event_bus.publish(@test_event)
			end

			it 'should notify all registered subscribers to that event' do
				@subscriber1.events_received.length.should == 1
				@subscriber1.events_received[0].should == @test_event
				@subscriber2.events_received.length.should == 1
				@subscriber2.events_received[0].should == @test_event
			end
		end
	end

	after(:all) do
		Object.send(:remove_const, :TestSubscriber)
	end
end