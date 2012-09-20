require 'spec_helper'

describe 'An aggregate root or entity class' do
	before(:all) do
		class TestAggRoot < Puree::Domain::AggregateRoot
			def initialize(id, name)
				super(id)
				@name = name
			end
		end

		class TestHeader < Puree::Domain::Entity
			def initialize(id, parent, title)
				super(id, parent)
				@title = title
			end
		end

		class TestItem < Puree::Domain::Entity
			def initialize(id, parent, name, quantity)
				super(id, parent)
				@name = name
				@quantity = quantity
			end
		end
	end

	it 'can implement state changes by signalling and applying events' do
		class TestAggRoot < Puree::Domain::AggregateRoot
			def change_name(name)
				signal_event :name_changed, from: @name, to: name
			end

			apply_event :name_changed do |event|
				@name = event.attributes[:to]
			end
		end

		class TestHeader < Puree::Domain::Entity
			def change_title(title)
				signal_event :title_changed, from: @title, to: title
			end

			apply_event :title_changed do |event|
				@title = event.attributes[:to]
			end
		end

		class TestItem < Puree::Domain::Entity
			def change_quantity(quantity)
				signal_event :quantity_changed, from: @quantity, to: quantity
			end

			apply_event :quantity_changed do |event|
				@quantity = event.attributes[:to]
			end
		end		
	end

	it 'can define associations with other entities' do
		class TestAggRoot < Puree::Domain::AggregateRoot
			has_a :header
			has_many :items

			def create_header(title)
				signal_event :header_created, id: 123, title: title  
			end

			def change_title(title)
				header.change_title(title)
			end

			def add_item(name, quantity)
				signal_event :item_added, id: 456, name: name, quantity: quantity
			end

			def change_item_quantity(item_id, quantity)
				item = items.find { |item| item.id == item_id }
				item.change_quantity(quantity)
			end

			apply_event :header_created do |event|
				set_header(TestHeader.new(event.attributes[:id], self, event.attributes[:title]))
			end

			apply_event :item_added do |event|
				items << TestItem.new(event.attributes[:id], self, event.attributes[:name], event.attributes[:quantity])
			end
		end
	end
end

describe 'An aggregate root instance' do
	let(:agg_root) { TestAggRoot.new(1, 'test1') }

	context 'when state-changing methods are called' do
		before(:each) do
			agg_root.change_name('test2')
			agg_root.create_header('test_header1')
			agg_root.change_title('test_header2')
			agg_root.add_item('item1', 2)
			agg_root.change_item_quantity(456, 3)
		end

		it 'should apply all events that occur within the aggregate' do
			agg_root.instance_variable_get(:@name).should == 'test2'
			agg_root.header.instance_variable_get(:@title).should == 'test_header2'
			item = agg_root.items.first
			item.instance_variable_get(:@name).should == 'item1'
			item.instance_variable_get(:@quantity).should == 3
		end

		it 'should track all events that occur within the aggregate' do
			agg_root.pending_events.length.should == 5
			agg_root.pending_events[0].aggregate_root_id.should == 1
			agg_root.pending_events[0].source_id.should == 1
			agg_root.pending_events[0].source_class_name.should == 'TestAggRoot'
			agg_root.pending_events[0].name.should == :name_changed
			agg_root.pending_events[0].attributes.should == { from: 'test1', to: 'test2' }
			agg_root.pending_events[1].aggregate_root_id.should == 1
			agg_root.pending_events[1].source_id.should == 1
			agg_root.pending_events[1].source_class_name.should == 'TestAggRoot'
			agg_root.pending_events[1].name.should == :header_created
			agg_root.pending_events[1].attributes.should == { id: 123, title: 'test_header1' }
			agg_root.pending_events[2].aggregate_root_id.should == 1
			agg_root.pending_events[2].source_id.should == 123
			agg_root.pending_events[2].source_class_name.should == 'TestHeader'
			agg_root.pending_events[2].name.should == :title_changed
			agg_root.pending_events[2].attributes.should == { from: 'test_header1', to: 'test_header2' }
			agg_root.pending_events[3].aggregate_root_id.should == 1
			agg_root.pending_events[3].source_id.should == 1
			agg_root.pending_events[3].source_class_name.should == 'TestAggRoot'
			agg_root.pending_events[3].name.should == :item_added
			agg_root.pending_events[3].attributes.should == { id: 456, name: 'item1', quantity: 2 }
			agg_root.pending_events[4].aggregate_root_id.should == 1
			agg_root.pending_events[4].source_id.should == 456
			agg_root.pending_events[4].source_class_name.should == 'TestItem'
			agg_root.pending_events[4].name.should == :quantity_changed
			agg_root.pending_events[4].attributes.should == { from: 2, to: 3 }
		end
	end

	context 'when the replay_events method is called' do
		before(:each) do
			events = [
				Puree::Domain::Event.new(1, 1, 'TestAggRoot', :name_changed, { from: 'test1', to: 'test2' }),
				Puree::Domain::Event.new(1, 1, 'TestAggRoot', :header_created, { id: 123, title: 'test_header1' }),
				Puree::Domain::Event.new(1, 123, 'TestHeader', :title_changed, { from: 'test_header1', to: 'test_header2' }),
				Puree::Domain::Event.new(1, 1, 'TestAggRoot', :item_added, { id: 456, name: 'item1', quantity: 2 }),
				Puree::Domain::Event.new(1, 456, 'TestItem', :quantity_changed, { from: 2, to: 3 })
			]
			agg_root.replay_events(events)
		end

		it 'should re-apply the events throughout the aggregate' do
			agg_root.pending_events.length.should == 0
			agg_root.instance_variable_get(:@name).should == 'test2'
			agg_root.header.instance_variable_get(:@title).should == 'test_header2'
			item = agg_root.items.first
			item.instance_variable_get(:@name).should == 'item1'
			item.instance_variable_get(:@quantity).should == 3
		end
	end

	after(:all) do
		Object.send(:remove_const, :TestAggRoot)
		Object.send(:remove_const, :TestHeader)
		Object.send(:remove_const, :TestItem)
	end
end