require 'spec_helper'

describe 'An aggregate root factory class' do
	before(:all) do
		class TestFactory < Puree::Domain::AggregateRootFactory
		end

		class TestAggRoot < Puree::Domain::AggregateRoot
			def initialize(id, name)
				super(id)
				@name = name
			end
		end
	end

	it 'can implement factory methods by signalling and applying events' do
		class TestFactory < Puree::Domain::AggregateRootFactory
			def create(name)
				signal_event :test_agg_root_created, id: 123, name: name
			end

			apply_event :test_agg_root_created do |event|
				TestAggRoot.new(event.attributes[:id], event.attributes[:name])
			end
		end
	end
end

describe 'An aggregate root factory instance' do
	let(:factory) { TestFactory.new }

	context 'when a factory method is called' do
		let(:agg_root) { factory.create('test1')}

		it 'should create an aggregate root instance' do
			agg_root.should be_an_instance_of(TestAggRoot)
			agg_root.aggregate_root_id.should == 123
			agg_root.id.should == 123
			agg_root.instance_variable_get(:@name).should == 'test1'
		end

		it 'should inject the creation event into that instance' do
			agg_root.pending_events.length.should == 1
			agg_root.pending_events[0].aggregate_root_id.should == 123
			agg_root.pending_events[0].source_id.should be_nil
			agg_root.pending_events[0].source_class_name.should == 'TestFactory'
			agg_root.pending_events[0].name.should == :test_agg_root_created
			agg_root.pending_events[0].attributes.should == { id: 123, name: 'test1' }
		end
	end

	context 'when the recreate method is called' do
		let(:agg_root) do
			creation_event = Puree::Domain::Event.new(1, nil, 'TestFactory', :test_agg_root_created, { id: 456, name: 'test2' } )
			factory.recreate(creation_event)
		end

		it 'should recreate the aggregate root instance by replaying the provided event' do
			agg_root.should be_an_instance_of(TestAggRoot)
			agg_root.aggregate_root_id.should == 456
			agg_root.id.should == 456
			agg_root.instance_variable_get(:@name).should == 'test2'
		end
	end

	after(:all) do
		Object.send(:remove_const, :TestFactory)
		Object.send(:remove_const, :TestAggRoot)
	end
end