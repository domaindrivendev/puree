require 'spec_helper'
require 'sample/models/sales'

describe 'An Aggregate Factory' do
	before(:all) do
		class OrderFactory < Puree::Domain::AggregateFactory
		end
	end

	context 'that implements factory methods by signalling and applying Events' do
		let(:factory) do
			class Order < Puree::Domain::AggregateRoot
				attr_identifier :order_no
				attr_reader :name

				def initialize(order_no, name)
					@order_no = order_no
					@name = name
				end
			end

			class OrderFactory < Puree::Domain::AggregateFactory
				creates Order

				def create(name)
					signal_event :order_created, order_no: next_order_no, name: name
				end

				apply_event :order_created do |args|
					Order.new(args[:order_no], args[:name])
				end
			end

			OrderFactory.new(Puree::Persistence::MemoryIdGenerator.new)
		end

		context 'when a factory method is called' do
			let(:order) { factory.create('my order') }

			it 'should create an Aggregate Root with the creation Event tracked' do
				order.should be_an_instance_of(Order)
				order.order_no.should == 1
				order.name.should == 'my order'

				order.pending_events.length.should == 1
				order.pending_events[0].source_identity_token.should == 'OrderFactory'
				order.pending_events[0].name.should == :order_created
				order.pending_events[0].args.should == { order_no: 1, name: 'my order' }
			end
		end

		context 'when the recreate method is called' do
			let(:order) do
				creation_event = Puree::Domain::Event.new('Order_1', :order_created, { order_no: 1, name: 'my order' } )
				factory.recreate(creation_event)
			end

			it 'should recreate the Aggregate Root by re-applying the creation Event' do
				order.should be_an_instance_of(Order)
				order.order_no.should == 1
				order.name.should == 'my order'
			end
		end
	end

	after(:all) do
		Object.send(:remove_const, :Order)
		Object.send(:remove_const, :OrderFactory)
		Puree.config.id_generator.reset
	end
end