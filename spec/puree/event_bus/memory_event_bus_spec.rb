require 'spec_helper'

describe 'A Memory Event Bus' do
	let(:event_bus) { Puree::EventBus::MemoryEventBus.new }

	context 'with Observers registered' do
		before(:each) do
			class TestObserver < Puree::EventBus::Observer
				def events_received
					@events_received ||= []
				end

				on_event :order_created do |event|
					events_received << event
				end

				on_event :item_added do |event|
					events_received << event
				end
			end

			@observer1 = TestObserver.new
			@observer2 = TestObserver.new

			event_bus.register(@observer1)
			event_bus.register(@observer2)
		end

		context 'when Events are published' do
			before(:each) do
				@event1 = Puree::Domain::Event.new('OrderFactory', :order_created, { order_no: 123, name: 'my order' })
				@event2 = Puree::Domain::Event.new('Order123', :item_added, { item_no: 1, product_name: 'product1', quantity: 2 })
				event_bus.publish(@event1)
				event_bus.publish(@event2)
			end

			it 'should notify all of the Observers' do
				@observer1.events_received.length.should == 2
				@observer1.events_received[0].should == @event1
				@observer1.events_received[1].should == @event2
				@observer2.events_received.length.should == 2
				@observer2.events_received[0].should == @event1
				@observer2.events_received[1].should == @event2
			end
		end
	end

	after(:all) do
		Object.send(:remove_const, :TestObserver)
	end
end