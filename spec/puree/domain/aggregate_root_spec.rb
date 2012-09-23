require 'spec_helper'

describe 'An Aggregate Root and associated Entities' do
	before(:all) do
		class Order < Puree::Domain::AggregateRoot
			has_a :header
			has_many :items

			def initialize(id, name)
				super(id)
				@name = name
			end
		end

		class Header < Puree::Domain::Entity
			def initialize(id, parent, title)
				super(id, parent)
				@title = title
			end
		end

		class OrderItem < Puree::Domain::Entity
			def initialize(id, parent, name, quantity)
				super(id, parent)
				@name = name
				@quantity = quantity
			end
		end
	end

	context 'that implements state changes by signalling and applying Events' do
		let(:order) do
			class Order < Puree::Domain::AggregateRoot
				def change_name(name)
					signal_event :name_changed, from: @name, to: name
				end

				def create_header(title)
					signal_event :header_created, id: 123, title: title  
				end

				def add_item(name, quantity)
					signal_event :item_added, id: 456, name: name, quantity: quantity
				end

				def change_title(title)
					header.change_title(title)
				end

				def change_item_quantity(item_id, quantity)
					item = items.find { |item| item.id == item_id }
					item.change_quantity(quantity)
				end

				apply_event :name_changed do |event|
					@name = event.attributes[:to]
				end

				apply_event :header_created do |event|
					set_header(Header.new(event.attributes[:id], self, event.attributes[:title]))
				end

				apply_event :item_added do |event|
					items << OrderItem.new(event.attributes[:id], self, event.attributes[:name], event.attributes[:quantity])
				end
			end

			class Header < Puree::Domain::Entity
				def change_title(title)
					signal_event :title_changed, from: @title, to: title
				end

				apply_event :title_changed do |event|
					@title = event.attributes[:to]
				end
			end

			class OrderItem < Puree::Domain::Entity
				def change_quantity(quantity)
					signal_event :quantity_changed, from: @quantity, to: quantity
				end

				apply_event :quantity_changed do |event|
					@quantity = event.attributes[:to]
				end
			end

			Order.new(1, 'order1')
		end

		context 'when state-changing methods are called' do
			before(:each) do
				order.change_name('order2')
				order.create_header('header1')
				order.add_item('item1', 2)
				order.change_title('header2')
				order.change_item_quantity(456, 3)
			end

			it 'should apply all Events that occur within the Aggregate' do
				order.instance_variable_get(:@name).should == 'order2'
				order.header.instance_variable_get(:@title).should == 'header2'
				item = order.items.first
				item.instance_variable_get(:@name).should == 'item1'
				item.instance_variable_get(:@quantity).should == 3
			end

			it 'should track all Events that occur within the Aggregate' do
				order.pending_events.length.should == 5
				order.pending_events[0].aggregate_root_id.should == 1
				order.pending_events[0].source_id.should == 1
				order.pending_events[0].source_class_name.should == 'Order'
				order.pending_events[0].name.should == :name_changed
				order.pending_events[0].attributes.should == { from: 'order1', to: 'order2' }
				order.pending_events[1].aggregate_root_id.should == 1
				order.pending_events[1].source_id.should == 1
				order.pending_events[1].source_class_name.should == 'Order'
				order.pending_events[1].name.should == :header_created
				order.pending_events[1].attributes.should == { id: 123, title: 'header1' }
				order.pending_events[2].aggregate_root_id.should == 1
				order.pending_events[2].source_id.should == 1
				order.pending_events[2].source_class_name.should == 'Order'
				order.pending_events[2].name.should == :item_added
				order.pending_events[2].attributes.should == { id: 456, name: 'item1', quantity: 2 }
				order.pending_events[3].aggregate_root_id.should == 1
				order.pending_events[3].source_id.should == 123
				order.pending_events[3].source_class_name.should == 'Header'
				order.pending_events[3].name.should == :title_changed
				order.pending_events[3].attributes.should == { from: 'header1', to: 'header2' }
				order.pending_events[4].aggregate_root_id.should == 1
				order.pending_events[4].source_id.should == 456
				order.pending_events[4].source_class_name.should == 'OrderItem'
				order.pending_events[4].name.should == :quantity_changed
				order.pending_events[4].attributes.should == { from: 2, to: 3 }
			end
		end

		context 'when the replay_events method is called' do
			before(:each) do
				events = [
					Puree::Domain::Event.new(1, 1, 'Order', :name_changed, { from: 'order1', to: 'order2' }),
					Puree::Domain::Event.new(1, 1, 'Order', :header_created, { id: 123, title: 'header1' }),
					Puree::Domain::Event.new(1, 1, 'Order', :item_added, { id: 456, name: 'item1', quantity: 2 }),
					Puree::Domain::Event.new(1, 123, 'Header', :title_changed, { from: 'header1', to: 'header2' }),
					Puree::Domain::Event.new(1, 456, 'OrderItem', :quantity_changed, { from: 2, to: 3 })
				]
				order.replay_events(events)
			end

			it 'should re-apply the Events within the Aggregate' do
				order.pending_events.length.should == 0
				order.instance_variable_get(:@name).should == 'order2'
				order.header.instance_variable_get(:@title).should == 'header2'
				item = order.items.first
				item.instance_variable_get(:@name).should == 'item1'
				item.instance_variable_get(:@quantity).should == 3
			end
		end
	end

	after(:all) do
		Object.send(:remove_const, :Order)
		Object.send(:remove_const, :Header)
		Object.send(:remove_const, :OrderItem)
	end
end