require 'spec_helper'

describe 'A subscriber class' do
	before(:each) do
		class Subscriber < Puree::EventBus::Subscriber
		end
	end

	it 'can implement code to execute when notified of an event' do
		class TestSubscriber < Puree::EventBus::Subscriber
			def events_received
				@events_received ||= []
			end

			on_event :test_event1 do |event|
				events_received << event
			end

			on_event :test_event2 do |event|
				events_received << event
			end
		end
	end
end

describe 'A subscriber instance' do
	let(:subscriber) { TestSubscriber.new }

	context 'when the notify method is called' do
		before(:each) do
			@test_event1 = Puree::Domain::Event.new(123, 123, 'TestAggRoot', :test_event1, { value: 10 })
			@test_event2 = Puree::Domain::Event.new(123, 123, 'TestAggRoot', :test_event2, { value: 10 })

			subscriber.notify(@test_event1)
			subscriber.notify(@test_event2)
		end

		it 'should execute the code block for that event' do
			subscriber.events_received.length.should == 2
			subscriber.events_received[0].should == @test_event1
			subscriber.events_received[1].should == @test_event2
		end
	end

	after(:all) do
		Object.send(:remove_const, :TestSubscriber)
	end
end