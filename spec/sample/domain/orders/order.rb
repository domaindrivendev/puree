module Domain
	module Orders

		class Order < Puree::Domain::AggregateRoot
			attr_identifier :order_no
			has_many :line_items
			has_a :summary

			def initialize(order_no, name)
				@order_no = order_no
				@name = name
				set_summary(Summary.new)
			end

			def add_item(product_code, price, quantity)
				if line_items.any? { |li| li.product_code == product_code }
					raise "Already a line item for product - #{product_code}"
				end

				signal_event :item_added, product_code: product_code, price: price, quantity: quantity
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

	end
end