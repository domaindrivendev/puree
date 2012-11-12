require 'spec_helper'
require 'spec_fakes'

describe 'An Event Store Repository' do
	before(:each) do
		@factory = OrderFactory.new
		@event_store = Puree::Persistence::MemoryEventStore.new()
		@event_bus = stub('event_bus')
		@event_bus.stub(:publish)

		@repository = Puree::Persistence::EventStoreRepository.new(@factory, @event_store, @event_bus)
	end

	context 'when the add method is called' do
		before(:each) do
			order = @factory.create(123, 'my order')
			order.add_item('product1', 2)
		
			@repository.add(order)
		end

		it 'should persist all pending Events for the new Aggregate Root' do
			persisted_events = @event_store.get_events('Order123')

			persisted_events.length.should == 2
			persisted_events[0].source_id_hash.should == 'OrderFactory'
			persisted_events[0].name.should == :order_created
			persisted_events[0].args.should == { order_no: 123, name: 'my order' }
			persisted_events[1].source_id_hash.should == 'Order123'
			persisted_events[1].name.should == :item_added
			persisted_events[1].args.should == { item_no: 1, product_name: 'product1', quantity: 2 }
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
				Puree::Domain::Event.new('OrderFactory', :order_created, { order_no: 123, name: 'my order' }),
				Puree::Domain::Event.new('Order123', :item_added, { item_no: 1, product_name: 'product1', quantity: 2 })
			]
			@event_store.register_aggregate_root('Order123')
			@event_store.add_events('Order123', events)
		
			@order = @repository.find(123)
		end

		it 'should recreate the Aggregate Root from persisted Events ' do
			@order.header.instance_variable_get(:@title).should == 'my order'
			item1 = @order.items.find { |item| item.item_no == 1 }
			item1.instance_variable_get(:@quantity).should == 2
		end
	end

	context 'when the update method is called' do
		before(:each) do
			events = [
				Puree::Domain::Event.new('OrderFactory', :order_created, { order_no: 123, name: 'my order' }),
				Puree::Domain::Event.new('Order123', :item_added, { item_no: 1, product_name: 'product1', quantity: 2 })
			]
			@event_store.register_aggregate_root('Order123')
			@event_store.add_events('Order123', events)
		
			order = @repository.find(123)
			order.add_item('product2', 3)
			@repository.update(order)
		end

		it 'should persist all pending Events for the provided Aggregate Root' do
			persisted_events = @event_store.get_events('Order123')

			persisted_events.length.should == 3
			persisted_events[0].source_id_hash.should == 'OrderFactory'
			persisted_events[0].name.should == :order_created
			persisted_events[0].args.should == { order_no: 123, name: 'my order' }
			persisted_events[1].source_id_hash.should == 'Order123'
			persisted_events[1].name.should == :item_added
			persisted_events[1].args.should == { item_no: 1, product_name: 'product1', quantity: 2 }
			persisted_events[2].source_id_hash.should == 'Order123'
			persisted_events[2].name.should == :item_added
			persisted_events[2].args.should == { item_no: 2, product_name: 'product2', quantity: 3 }
		end

		it 'should publish the pending Events to the Event Bus' do
			# TODO:
		end	
	end
end