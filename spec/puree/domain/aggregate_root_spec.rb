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
					item = items.find(item_no)
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
					signal_event :quantity_changed, old_quantity: @quantity, new_quantity: quantity
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
				order.change_header_title('my awesome order')
				order.change_item_quantity(1, 3)
			end

			it 'should apply all Events that occur within the Aggregate' do
				item = order.items.first
				item.item_no.should == 1
				item.instance_variable_get(:@product_name).should == 'product1'
				item.instance_variable_get(:@quantity).should == 3
			end

			it 'should track all Events that occur within the Aggregate' do
				order.pending_events.length.should == 3
				order.pending_events[0].root_id.should == 123
				order.pending_events[0].name.should == :item_added
				order.pending_events[0].args.should == { item_no: 1, name: 'product1', quantity: 2 }
				order.pending_events[1].root_id.should == 123
				order.pending_events[1].name.should == :title_changed
				order.pending_events[1].args.should == { old_title: 'my order', new_title: 'my awesome order' }
				order.pending_events[2].root_id.should == 123
				order.pending_events[2].name.should == :quantity_changed
				order.pending_events[2].args.should == { old_quantity: 2, new_quantity: 3 }
			end
		end

		# context 'when the replay_events method is called' do
		# 	before(:each) do
		# 		events = [
		# 			Puree::Domain::Event.new('Order', 1, 'Order', 1, :name_changed, { from: 'order1', to: 'order2' }),
		# 			Puree::Domain::Event.new('Order', 1, 'Order', 1, :header_created, { id: 1, title: 'header1' }),
		# 			Puree::Domain::Event.new('Order', 1, 'Order', 1, :item_added, { id: 1, name: 'item1', quantity: 2 }),
		# 			Puree::Domain::Event.new('Order', 1, 'Header', 1, :title_changed, { from: 'header1', to: 'header2' }),
		# 			Puree::Domain::Event.new('Order', 1, 'OrderItem', 1, :quantity_changed, { from: 2, to: 3 })
		# 		]
		# 		order.replay_events(events)
		# 	end

		# 	it 'should re-apply the Events within the Aggregate' do
		# 		order.pending_events.length.should == 0
		# 		order.instance_variable_get(:@name).should == 'order2'
		# 		order.header.instance_variable_get(:@title).should == 'header2'
		# 		item = order.items.first
		# 		item.instance_variable_get(:@name).should == 'item1'
		# 		item.instance_variable_get(:@quantity).should == 3
		# 	end
		# end
	end

	after(:all) do
		Object.send(:remove_const, :Order)
		Object.send(:remove_const, :Header)
		Object.send(:remove_const, :Item)
	end
end