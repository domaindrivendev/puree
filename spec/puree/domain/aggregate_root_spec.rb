require 'spec_helper'

describe 'An Aggregate Root and associated Entities' do
	before(:all) do
		class Order < Puree::Domain::AggregateRoot
			identifiable_by :order_no
			has_a :header
			has_many :items

			def initialize(order_no, name)
				@order_no = order_no
				set_header(Header.new(name))

				@next_item_no = 1
			end
		end

		class Header < Puree::Domain::Entity
			def initialize(title)
				@title = title
			end
		end

		class Item < Puree::Domain::Entity
			identifiable_by :item_no

			def initialize(item_no, product_name, quantity)
				@item_no = item_no
				@product_name = product_name
				@quantity = quantity
			end
		end
	end

	context 'that implements state changes by signalling and applying Events' do
		let(:order) do
			class Order < Puree::Domain::AggregateRoot

				def add_item(product_name, quantity)
					signal_event :item_added, item_no: @next_item_no, product_name: product_name, quantity: quantity
				end

				def change_header_title(title)
					header.change_title(title)
				end

				def change_item_quantity(item_no, quantity)
					item = items.find { |item| item.item_no == item_no }
					item.change_quantity(quantity)
				end

				apply_event :item_added do |event|
					items << Item.new(
						event.args[:item_no],
						event.args[:product_name],
						event.args[:quantity])

					@next_item_no += 1
				end
			end

			class Header < Puree::Domain::Entity
				def change_title(title)
					signal_event :title_changed, old_title: @title, new_title: title
				end

				apply_event :title_changed do |event|
					@title = event.args[:new_title]
				end
			end

			class Item < Puree::Domain::Entity
				def change_quantity(quantity)
					signal_event :quantity_changed, item_no: item_no, old_quantity: @quantity, new_quantity: quantity
				end

				apply_event :quantity_changed do |event|
					@quantity = event.args[:new_quantity]
				end
			end

			order = Order.new(123, 'my order')
		end

		context 'when state-changing methods are called' do
			before(:each) do
				order.add_item('product1', 2)
				order.add_item('product2', 3)
				order.change_header_title('my awesome order')
				order.change_item_quantity(1, 4)
				order.change_item_quantity(2, 5)
			end

			it 'should apply all Events that occur within the Aggregate' do
				order.header.instance_variable_get(:@title).should == 'my awesome order'
				item1 = order.items.find { |item| item.item_no == 1 }
				item1.instance_variable_get(:@quantity).should == 4
				item2 = order.items.find { |item| item.item_no == 2 }
				item2.instance_variable_get(:@quantity).should == 5
			end

			it 'should track all Events that occur within the Aggregate' do
				order.pending_events.length.should == 5
				order.pending_events[0].source_id_token.should == 'Order123'
				order.pending_events[0].name.should == :item_added
				order.pending_events[0].args.should == { item_no: 1, product_name: 'product1', quantity: 2 }
				order.pending_events[1].source_id_token.should == 'Order123'
				order.pending_events[1].name.should == :item_added
				order.pending_events[1].args.should == { item_no: 2, product_name: 'product2', quantity: 3 }
				order.pending_events[2].source_id_token.should == 'Header' 
				order.pending_events[2].name.should == :title_changed
				order.pending_events[2].args.should == { old_title: 'my order', new_title: 'my awesome order' }
				order.pending_events[3].source_id_token.should == 'Item1'
				order.pending_events[3].name.should == :quantity_changed
				order.pending_events[3].args.should == { item_no: 1, old_quantity: 2, new_quantity: 4 }
				order.pending_events[4].source_id_token.should == 'Item2'
				order.pending_events[4].name.should == :quantity_changed
				order.pending_events[4].args.should == { item_no: 2, old_quantity: 3, new_quantity: 5 }
			end
		end

		context 'when the replay_events method is called' do
			before(:each) do
				events = [
					Puree::Domain::Event.new('Order123', :item_added, { item_no: 1, name: 'product1', quantity: 2 }),
					Puree::Domain::Event.new('Order123', :item_added, { item_no: 2, name: 'product2', quantity: 3 }),
					Puree::Domain::Event.new('Header', :title_changed, { old_title: 'my order', new_title: 'my awesome order' }),
					Puree::Domain::Event.new('Item1', :quantity_changed, { item_no: 1, old_quantity: 2, new_quantity: 4 }),
					Puree::Domain::Event.new('Item2', :quantity_changed, { item_no: 2, old_quantity: 3, new_quantity: 5 })
				]
				order.replay_events(events)
			end

			it 'should re-apply the Events within the Aggregate' do
				order.pending_events.length.should == 0
				order.header.instance_variable_get(:@title).should == 'my awesome order'
				item1 = order.items.find { |item| item.item_no == 1 }
				item1.instance_variable_get(:@quantity).should == 4
				item2 = order.items.find { |item| item.item_no == 2 }
				item2.instance_variable_get(:@quantity).should == 5
			end
		end
	end

	after(:all) do
		Object.send(:remove_const, :Order)
		Object.send(:remove_const, :Header)
		Object.send(:remove_const, :Item)
	end
end