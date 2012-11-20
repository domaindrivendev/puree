require 'spec_helper'
require 'sample/domain/orders'

describe 'An Event Store Repository' do
	before(:each) do
		@factory = Domain::Orders::OrderFactory.new(Puree::Persistence::MemoryIdGenerator.new)
		@event_store = Puree::Persistence::MemoryEventStore.new()
		@event_bus = stub('event_bus')
		@event_bus.stub(:publish)

		@repository = Puree::Persistence::EventStoreRepository.new(@factory, @event_store, @event_bus)
	end

	context 'when the add method is called' do
		before(:each) do
			order = @factory.create('my order')
			order.add_item('product1', 10.0, 2)
		
			@repository.add(order)
		end

		it 'should persist all pending Events from the provided Aggregate Root' do
			persisted_events = @event_store.get_aggregate_events('Domain::Orders::Order_1')

			persisted_events.length.should == 2
			persisted_events[0].source_identity_token.should == 'Domain::Orders::OrderFactory'
			persisted_events[0].name.should == :order_created
			persisted_events[0].args.should ==
				{ order_no: 1, name: 'my order' }
			persisted_events[1].source_identity_token.should == 'Domain::Orders::Order_1'
			persisted_events[1].name.should == :item_added
			persisted_events[1].args.should ==
				{ order_no: 1, product_code: 'product1', price: 10.0, quantity: 2 }
		end

		it 'should publish the pending Events to the Event Bus' do
			# TODO:
			# event1 = Puree::Domain::Event.new('OrderFactory', :order_created, { order_no: 123, name: 'my order'})
			# @event_bus.should have_received(:publish).with(event1)
		end	
	end

	context 'when the find method is called' do
		before(:each) do
			events = [
				Puree::Domain::Event.new('Domain::Orders::OrderFactory', :order_created,
					{ order_no: 1, name: 'my order' }),
				Puree::Domain::Event.new('Domain::Orders::Order_1', :item_added,
					{ order_no: 1, product_code: 'product1', price: 10.0, quantity: 2 })
			]
			@event_store.register_aggregate('Domain::Orders::Order_1')
			@event_store.add_aggregate_events('Domain::Orders::Order_1', events)
		
			@order = @repository.find(1)
		end

		it 'should recreate the Aggregate Root from persisted Events ' do
			@order.instance_variable_get(:@name).should == 'my order'
			line_item1 = @order.line_items.find { |li| li.product_code == 'product1' }
			line_item1.instance_variable_get(:@quantity).should == 2
		end
	end

	context 'when the update method is called' do
		before(:each) do
			events = [
				Puree::Domain::Event.new('Domain::Orders::OrderFactory', :order_created,
					{ order_no: 1, name: 'my order' }),
				Puree::Domain::Event.new('Domain::Orders::Order_1', :item_added,
					{ order_no: 1, product_code: 'product1', price: 10.0, quantity: 2 })
			]
			@event_store.register_aggregate('Domain::Orders::Order_1')
			@event_store.add_aggregate_events('Domain::Orders::Order_1', events)
		
			order = @repository.find(1)
			order.add_item('product2', 15.0, 3)
			@repository.update(order)
		end

		it 'should persist all pending Events from the provided Aggregate Root' do
			persisted_events = @event_store.get_aggregate_events('Domain::Orders::Order_1')

			persisted_events.length.should == 3
			persisted_events[0].source_identity_token.should == 'Domain::Orders::OrderFactory'
			persisted_events[0].name.should == :order_created
			persisted_events[0].args.should ==
				{ order_no: 1, name: 'my order' }
			persisted_events[1].source_identity_token.should == 'Domain::Orders::Order_1'
			persisted_events[1].name.should == :item_added
			persisted_events[1].args.should ==
				{ order_no: 1, product_code: 'product1', price: 10.0, quantity: 2 }
			persisted_events[2].source_identity_token.should == 'Domain::Orders::Order_1'
			persisted_events[2].name.should == :item_added
			persisted_events[2].args.should ==
				{ order_no: 1, product_code: 'product2', price: 15.0, quantity: 3 }
		end

		it 'should publish the pending Events to the Event Bus' do
			# TODO:
		end	
	end
end