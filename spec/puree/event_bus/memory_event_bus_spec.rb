require 'spec_helper'

describe 'A Memory Event Bus' do
	let(:event_bus) { Puree::EventBus::MemoryEventBus.new }

	context 'with registered Subscribers to an Event' do
		before(:each) do
			class TestSubscriber < Puree::EventBus::Subscriber
				def events_received
					@events_received ||= []
				end

				on_event :order_created do |event|
					events_received << event
				end
			end

			@subscriber1 = TestSubscriber.new
			@subscriber2 = TestSubscriber.new

			event_bus.register(@subscriber1)
			event_bus.register(@subscriber2)
		end

		context 'when that Event is published' do
			before(:each) do
				@test_event = Puree::Domain::Event.new('Order', 123, 'OrderFactory', nil, :order_created, { id: 123, name: 'order1' })
				event_bus.publish(@test_event)
			end

			it 'should notify all of the Subscribers' do
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