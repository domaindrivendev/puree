require 'spec_helper'

describe 'An event store repository instance' do
	before(:each) do
		class TestFactory < Puree::Domain::AggregateRootFactory
			def create(name)
				signal_event :test_agg_root_created, id: 123, name: name
			end

			apply_event :test_agg_root_created do |event|
				TestAggRoot.new(event.attributes[:id], event.attributes[:name])
			end
		end

		class TestAggRoot < Puree::Domain::AggregateRoot
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

		@factory = TestFactory.new
		@event_store = Puree::Persistence::MemoryEventStore.new()
		@event_bus = Puree::EventBus::MemoryEventBus.new()
		@repository = Puree::Persistence::EventStoreRepository.new(@factory, @event_store, @event_bus)
	end

	context 'when the save method is called' do
		before(:each) do
			@agg_root = @factory.create('test1')
			@agg_root.change_name('test2')
		
			@repository.save(@agg_root)
		end

		it 'should persist all pending events from the aggregate root' do
			persisted_events = @event_store.get_by_aggregate_root_id(@agg_root.id)

			persisted_events.length.should == 2
			persisted_events[0].aggregate_root_id.should == 123
			persisted_events[0].source_id.should == nil
			persisted_events[0].source_class_name.should == 'TestFactory'
			persisted_events[0].name.should == :test_agg_root_created
			persisted_events[0].attributes.should == { id: 123, name: 'test1' }
			persisted_events[1].aggregate_root_id.should == 123
			persisted_events[1].source_id.should == 123
			persisted_events[1].source_class_name.should == 'TestAggRoot'
			persisted_events[1].name.should == :name_changed
			persisted_events[1].attributes.should == { from: 'test1', to: 'test2' }
		end
	end

	context 'when the get_by_id method is called' do
		before(:each) do
			events = [
				Puree::Domain::Event.new(123, nil, 'TestFactory', :test_agg_root_created, { id: 123, name: 'test1' }),
				Puree::Domain::Event.new(123, 123, 'TestAggRoot', :name_changed, { from: 'test1', to: 'test2' })
			]
			events.each do |event|
				@event_store.save(event)
			end
		
			@agg_root = @repository.get_by_id(123)
		end

		it 'should recreate the aggregate root from persisted events ' do
			@agg_root.should be_an_instance_of(TestAggRoot)
			@agg_root.pending_events.length.should == 0
			@agg_root.instance_variable_get(:@name).should == 'test2'
		end
	end

	after(:all) do
		Object.send(:remove_const, :TestFactory)
		Object.send(:remove_const, :TestAggRoot)
	end
end