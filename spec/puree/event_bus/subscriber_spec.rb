require 'spec_helper'

describe 'A Subscriber' do
	before(:each) do
		class Subscriber < Puree::EventBus::Subscriber
		end
	end

	context 'that implements code to execute when notified of a specific Event' do
		let(:subscriber) do
			class TestSubscriber < Puree::EventBus::Subscriber
				def events_received
					@events_received ||= []
				end

				on_event :order_created do |event|
					events_received << event
				end

				on_event :name_changed do |event|
					events_received << event
				end
			end

			TestSubscriber.new
		end

		context 'when the notify method is called' do
			before(:each) do
				@event1 = Puree::Domain::Event.new('Order', 123, 'OrderFactory', nil, :order_created, { id: 123, name: 'order1' })
				@event2 = Puree::Domain::Event.new('Order', 123, 'Order', 123, :name_changed, { from: 'order1', to: 'order2' })

				subscriber.notify(@event1)
				subscriber.notify(@event2)
			end

			it 'should execute the code for the provided event' do
				subscriber.events_received.length.should == 2
				subscriber.events_received[0].should == @event1
				subscriber.events_received[1].should == @event2
			end
		end
	end

	after(:all) do
		Object.send(:remove_const, :TestSubscriber)
	end
end