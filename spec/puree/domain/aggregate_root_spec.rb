require 'spec_helper'

describe 'An Aggregate Root and associated Entities' do
	before(:all) do
		class Order < Puree::Domain::AggregateRoot
			attr_identifier :order_no
			has_many :lines
			has_a :summary

			def initialize(order_no, name)
				@order_no = order_no
				@name = name
				set_summary(Summary.new)
			end
		end

		class Line < Puree::Domain::Entity
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

				def add_line(product_code, price, quantity)
					if lines.any? { |l| l.product_code == product_code }
						raise "Already a line for product - #{product_code}"
					end

					signal_event :line_added,
						product_code: product_code,
						price: price,
						quantity: quantity
				end

				def change_line_quantity(product_code, quantity)
					line = lines.find { |l| l.product_code == product_code }
					if line.nil?
						raise "Line not found for product - #{product_code}"
					end

					line.change_quantity(quantity)
				end

				def calculate_totals(tax_rate)
					gross_total = 0
					lines.each { |l| gross_total += l.total }
					summary.calculate_totals(gross_total, tax_rate)
				end

				apply_event :line_added do |args|
					lines << Line.new(args[:product_code], args[:price], args[:quantity])
				end
			end

			class Line < Puree::Domain::Entity
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
				def calculate_totals(gross_total, tax_rate)
					tax_amount = gross_total * tax_rate
					net_total = gross_total + tax_amount

					signal_event :totals_calculated,
						gross_total: gross_total,
						tax_rate: tax_rate,
						tax_amount: tax_amount,
						net_total: net_total
				end

				apply_event :totals_calculated do |args|
					@gross_total = args[:gross_total]
					@tax_rate = args[:tax_rate]
					@tax_amount = args[:tax_amount]
					@net_total = args[:net_total]
				end
			end

			Order.new(123, 'my order')
		end

		context 'when state-changing methods are called' do
			before(:each) do
				order.add_line('product1', 10.0, 2)
				order.add_line('product2', 15.0, 3)
				order.change_line_quantity('product1', 4)
				order.change_line_quantity('product2', 5)
				order.calculate_totals(0.1)
			end

			it 'should apply all Events that occur within the Aggregate' do
				order.instance_variable_get(:@name).should == 'my order'
				line1 = order.lines.find { |l| l.product_code == 'product1' }
				line1.instance_variable_get(:@quantity).should == 4
				line2 = order.lines.find { |l| l.product_code == 'product2' }
				line2.instance_variable_get(:@quantity).should == 5
				order.summary.instance_variable_get(:@net_total).should == 126.5
			end

			it 'should track all Events that occur within the Aggregate' do
				order.pending_events.length.should == 5
				order.pending_events[0].source_identity_token.should == 'Order_123'
				order.pending_events[0].name.should == :line_added
				order.pending_events[0].args.should ==
					{ order_no: 123, product_code: 'product1', price: 10.0, quantity: 2 }
				order.pending_events[1].source_identity_token.should == 'Order_123'
				order.pending_events[1].name.should == :line_added
				order.pending_events[1].args.should ==
					{ order_no: 123, product_code: 'product2', price: 15.0, quantity: 3 }
				order.pending_events[2].source_identity_token.should == 'Line_product1'
				order.pending_events[2].name.should == :quantity_changed
				order.pending_events[2].args.should ==
					{ order_no: 123, product_code: 'product1', old_quantity: 2, new_quantity: 4 }
				order.pending_events[3].source_identity_token.should == 'Line_product2'
				order.pending_events[3].name.should == :quantity_changed
				order.pending_events[3].args.should ==
					{ order_no: 123, product_code: 'product2', old_quantity: 3, new_quantity: 5 }
				order.pending_events[4].source_identity_token.should == 'Summary' 
				order.pending_events[4].name.should == :totals_calculated
				order.pending_events[4].args.should ==
					{ order_no: 123, gross_total: 115.0, tax_rate: 0.1, tax_amount: 11.5, net_total: 126.5 }
			end
		end

		context 'when the replay_events method is called' do
			before(:each) do
				events = [
					Puree::Domain::Event.new('Order_123', :line_added,
						{ product_code: 'product1', price: 10.0, quantity: 2 }),
					Puree::Domain::Event.new('Order_123', :line_added,
						{ product_code: 'product2', price: 15.0, quantity: 3 }),
					Puree::Domain::Event.new('Line_product1', :quantity_changed,
						{ product_code: 'product1', old_quantity: 2, new_quantity: 4 }),
					Puree::Domain::Event.new('Line_product2', :quantity_changed,
						{ product_code: 'product2', old_quantity: 3, new_quantity: 5 }),
					Puree::Domain::Event.new('Summary', :totals_calculated,
						{ gross_total: 115.0, tax_rate: 0.10, tax_amount: 11.50, net_total: 126.50 })
				]
				order.replay_events(events)
			end

			it 'should re-apply the Events within the Aggregate' do
				order.instance_variable_get(:@name).should == 'my order'
				line1 = order.lines.find { |l| l.product_code == 'product1' }
				line1.instance_variable_get(:@quantity).should == 4
				line2 = order.lines.find { |l| l.product_code == 'product2' }
				line2.instance_variable_get(:@quantity).should == 5
				order.summary.instance_variable_get(:@net_total).should == 126.50
			end
		end
	end

	after(:all) do
		Object.send(:remove_const, :Order)
		Object.send(:remove_const, :Line)
		Object.send(:remove_const, :Summary)
	end
end