require 'spec_helper'

describe 'An Aggregate Root and associated Entities' do
	before(:all) do
		class Order < Puree::Domain::AggregateRoot
			attr_identifier :order_no
			has_many :line_items
			has_a :summary

			def initialize(order_no, name)
				@order_no = order_no
				@name = name
				set_summary(Summary.new)
			end
		end

		class LineItem < Puree::Domain::Entity
			attr_identifier :product_code

			def initialize(product_code, price, quantity)
				@product_code = product_code
				@price = price
				@quantity = quantity
			end
		end

		class Summary < Puree::Domain::Entity
			def initialize
				@gross_total = 0.0
				@tax_rate = 0.0
				@tax_amount = 0.0
				@net_total = 0.0
			end
		end
	end

	context 'that implements state changes by signalling and applying Events' do
		let(:order) do
			class Order < Puree::Domain::AggregateRoot

				def add_item(product_code, price, quantity)
					if line_items.any? { |li| li.product_code == product_code }
						raise "Already a line item for product - #{product_code}"
					end

					signal_event :item_added,
						product_code: product_code,
						price: price,
						quantity: quantity
				end

				def change_item_quantity(product_code, quantity)
					line_item = line_items.find { |li| li.product_code == product_code }
					if line_item.nil?
						raise "Line item not found for product - #{product_code}"
					end

					line_item.change_quantity(quantity)
				end

				def calculate_total(tax_rate)
					gross_total = 0
					line_items.each { |li| gross_total += li.total }
					summary.calculate_total(gross_total, tax_rate)
				end

				apply_event :item_added do |args|
					line_items << LineItem.new(args[:product_code], args[:price], args[:quantity])
				end
			end

			class LineItem < Puree::Domain::Entity
				def change_quantity(quantity)
					signal_event :quantity_changed, old_quantity: @quantity, new_quantity: quantity
				end

				def total
					@quantity * @price
				end

				apply_event :quantity_changed do |args|
					@quantity = args[:new_quantity]
				end
			end

			class Summary < Puree::Domain::Entity
				def calculate_total(gross_total, tax_rate)
					tax_amount = gross_total * tax_rate
					net_total = gross_total + tax_amount

					signal_event :total_calculated,
						gross_total: gross_total,
						tax_rate: tax_rate,
						tax_amount: tax_amount,
						net_total: net_total
				end

				apply_event :total_calculated do |args|
					@net_total = args[:net_total]
				end
			end

			Order.new(123, 'my order')
		end

		context 'when state-changing methods are called' do
			before(:each) do
				order.add_item('product1', 10.0, 2)
				order.add_item('product2', 15.0, 3)
				order.change_item_quantity('product1', 4)
				order.change_item_quantity('product2', 5)
				order.calculate_total(0.1)
			end

			it 'should apply all Events that occur within the Aggregate' do
				order.instance_variable_get(:@name).should == 'my order'
				line_item1 = order.line_items.find { |li| li.product_code == 'product1' }
				line_item1.instance_variable_get(:@quantity).should == 4
				line_item2 = order.line_items.find { |li| li.product_code == 'product2' }
				line_item2.instance_variable_get(:@quantity).should == 5
				order.summary.instance_variable_get(:@net_total).should == 126.5
			end

			it 'should track all Events that occur within the Aggregate' do
				order.pending_events.length.should == 5
				order.pending_events[0].source_identity_token.should == 'Order_123'
				order.pending_events[0].name.should == :item_added
				order.pending_events[0].args.should ==
					{ order_no: 123, product_code: 'product1', price: 10.0, quantity: 2 }
				order.pending_events[1].source_identity_token.should == 'Order_123'
				order.pending_events[1].name.should == :item_added
				order.pending_events[1].args.should ==
					{ order_no: 123, product_code: 'product2', price: 15.0, quantity: 3 }
				order.pending_events[2].source_identity_token.should == 'LineItem_product1'
				order.pending_events[2].name.should == :quantity_changed
				order.pending_events[2].args.should ==
					{ order_no: 123, product_code: 'product1', old_quantity: 2, new_quantity: 4 }
				order.pending_events[3].source_identity_token.should == 'LineItem_product2'
				order.pending_events[3].name.should == :quantity_changed
				order.pending_events[3].args.should ==
					{ order_no: 123, product_code: 'product2', old_quantity: 3, new_quantity: 5 }
				order.pending_events[4].source_identity_token.should == 'Summary' 
				order.pending_events[4].name.should == :total_calculated
				order.pending_events[4].args.should ==
					{ order_no: 123, gross_total: 115.0, tax_rate: 0.1, tax_amount: 11.5, net_total: 126.5 }
			end
		end

		context 'when the replay_events method is called' do
			before(:each) do
				events = [
					Puree::Domain::Event.new('Order_123', :item_added,
						{ product_code: 'product1', price: 10.0, quantity: 2 }),
					Puree::Domain::Event.new('Order_123', :item_added,
						{ product_code: 'product2', price: 15.0, quantity: 3 }),
					Puree::Domain::Event.new('LineItem_product1', :quantity_changed,
						{ product_code: 'product1', old_quantity: 2, new_quantity: 4 }),
					Puree::Domain::Event.new('LineItem_product2', :quantity_changed,
						{ product_code: 'product2', old_quantity: 3, new_quantity: 5 }),
					Puree::Domain::Event.new('Summary', :total_calculated,
						{ gross_total: 115.0, tax_rate: 0.10, tax_amount: 11.50, net_total: 126.50 })
				]
				order.replay_events(events)
			end

			it 'should re-apply the Events within the Aggregate' do
				order.instance_variable_get(:@name).should == 'my order'
				line_item1 = order.line_items.find { |li| li.product_code == 'product1' }
				line_item1.instance_variable_get(:@quantity).should == 4
				line_item2 = order.line_items.find { |li| li.product_code == 'product2' }
				line_item2.instance_variable_get(:@quantity).should == 5
				order.summary.instance_variable_get(:@net_total).should == 126.50
			end
		end
	end

	after(:all) do
		Object.send(:remove_const, :Order)
		Object.send(:remove_const, :LineItem)
		Object.send(:remove_const, :Summary)
	end
end