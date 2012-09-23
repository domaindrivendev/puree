require 'spec_helper'

describe 'An Event Store Repository' do
	before(:each) do
		class OrderFactory < Puree::Domain::AggregateRootFactory
			def create(name)
				signal_event :order_created, id: 123, name: name
			end

			apply_event :order_created do |event|
				Order.new(event.attributes[:id], event.attributes[:name])
			end
		end

		class Order < Puree::Domain::AggregateRoot
			def initialize(id, name)
				super(id)
				@name = name
			end

			def change_name(name)
				signal_event :name_changed, from: @name, to: name
			end

			apply_event :name_changed do |event|
				@name = event.attributes[:to]
			end
		end

		@factory = OrderFactory.new(Puree::Persistence::MemoryIdGenerator.new)
		@event_store = Puree::Persistence::MemoryEventStore.new()
		@event_bus = Puree::EventBus::MemoryEventBus.new()
		@repository = Puree::Persistence::EventStoreRepository.new(@factory, @event_store, @event_bus)
	end

	context 'when the save method is called' do
		before(:each) do
			@order = @factory.create('order1')
			@order.change_name('order2')
		
			@repository.save(@order)
		end

		it 'should persist all pending Events in the Aggregate Root' do
			persisted_events = @event_store.get_by_aggregate_root_id(@order.id)

			persisted_events.length.should == 2
			persisted_events[0].aggregate_root_id.should == 123
			persisted_events[0].source_id.should == nil
			persisted_events[0].source_class_name.should == 'OrderFactory'
			persisted_events[0].name.should == :order_created
			persisted_events[0].attributes.should == { id: 123, name: 'order1' }
			persisted_events[1].aggregate_root_id.should == 123
			persisted_events[1].source_id.should == 123
			persisted_events[1].source_class_name.should == 'Order'
			persisted_events[1].name.should == :name_changed
			persisted_events[1].attributes.should == { from: 'order1', to: 'order2' }
		end
	end

	context 'when the get_by_id method is called' do
		before(:each) do
			events = [
				Puree::Domain::Event.new(123, nil, 'OrderFactory', :order_created, { id: 123, name: 'order1' }),
				Puree::Domain::Event.new(123, 123, 'Order', :name_changed, { from: 'order1', to: 'order2' })
			]
			events.each do |event|
				@event_store.save(event)
			end
		
			@order = @repository.get_by_id(123)
		end

		it 'should recreate the Aggregate Root from persisted Events ' do
			@order.should be_an_instance_of(Order)
			@order.pending_events.length.should == 0
			@order.aggregate_root_id.should == 123
			@order.id.should == 123
			@order.instance_variable_get(:@name).should == 'order2'
		end
	end

	after(:all) do
		Object.send(:remove_const, :OrderFactory)
		Object.send(:remove_const, :Order)
	end
end