require 'spec_helper'

describe 'An Aggregate Root Factory' do
	before(:all) do
		class OrderFactory < Puree::Domain::AggregateRootFactory
		end

		class Order < Puree::Domain::AggregateRoot
			identifiable_by :order_no

			def initialize(order_no, name)
				@order_no = order_no
				@name = name
			end
		end
	end

	context 'that implements factory methods by signalling and applying Events' do
		let(:factory) do
			class OrderFactory < Puree::Domain::AggregateRootFactory
				def create(order_no, name)
					signal_event :order_created, order_no: order_no, name: name
				end

				apply_event :order_created do |event|
					Order.new(event.args[:order_no], event.args[:name])
				end
			end

			OrderFactory.new()
		end

		context 'when the factory method is called' do
			let(:order) { factory.create(123, 'order1') }

			it 'should create an Aggregate Root with the0 creation Event tracked' do
				order.should be_an_instance_of(Order)
				order.order_no.should == 123
				order.instance_variable_get(:@name).should == 'order1'

				order.pending_events.length.should == 1
				# order.pending_events[0].root_id.should == 123
				order.pending_events[0].name.should == :order_created
				order.pending_events[0].args.should == { order_no: 123, name: 'order1' }
			end
		end

		context 'when the recreate method is called' do
			let(:order) do
				creation_event = Puree::Domain::Event.new(123, :order_created, { order_no: 123, name: 'order1' } )
				factory.recreate(creation_event)
			end

			it 'should recreate the Aggregate Root by re-applying the creation Event' do
				order.should be_an_instance_of(Order)
				order.order_no.should == 123
				order.instance_variable_get(:@name).should == 'order1'
			end
		end
	end

	after(:all) do
		Object.send(:remove_const, :OrderFactory)
		Object.send(:remove_const, :Order)
	end
end