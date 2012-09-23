require 'spec_helper'

describe 'An Aggregate Root Factory' do
	before(:all) do
		class OrderFactory < Puree::Domain::AggregateRootFactory
		end

		class Order < Puree::Domain::AggregateRoot
			def initialize(id, name)
				super(id)
				@name = name
			end
		end
	end

	context 'that implements factory methods by signalling and applying Events' do
		let(:factory) do
			class OrderFactory < Puree::Domain::AggregateRootFactory
				def create(name)
					signal_event :order_created, id: next_id, name: name
				end

				apply_event :order_created do |event|
					Order.new(event.attributes[:id], event.attributes[:name])
				end
			end

			OrderFactory.new(Puree::Persistence::MemoryIdGenerator.new)
		end

		context 'when the factory method is called' do
			let(:order) { factory.create('order1') }

			it 'should create an Aggregate Root with the creation Event tracked' do
				order.should be_an_instance_of(Order)
				order.aggregate_root_id.should == 1
				order.id.should == 1
				order.instance_variable_get(:@name).should == 'order1'

				order.pending_events.length.should == 1
				order.pending_events[0].aggregate_root_id.should == 1
				order.pending_events[0].source_id.should be_nil
				order.pending_events[0].source_class_name.should == 'OrderFactory'
				order.pending_events[0].name.should == :order_created
				order.pending_events[0].attributes.should == { id: 1, name: 'order1' }
			end
		end

		context 'when the recreate method is called' do
			let(:order) do
				creation_event = Puree::Domain::Event.new(1, nil, 'OrderFactory', :order_created, { id: 123, name: 'order1' } )
				factory.recreate(creation_event)
			end

			it 'should recreate the Aggregate Root by re-applying the creation Event' do
				order.should be_an_instance_of(Order)
				order.aggregate_root_id.should == 123
				order.id.should == 123
				order.instance_variable_get(:@name).should == 'order1'
			end
		end
	end

	after(:all) do
		Object.send(:remove_const, :OrderFactory)
		Object.send(:remove_const, :Order)
	end
end