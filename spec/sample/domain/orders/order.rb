module Domain
	module Orders

		class Order < Puree::Domain::AggregateRoot
			attr_identifier :order_no
			has_many :lines
			has_a :summary

			def initialize(order_no, name)
				@order_no = order_no
				@name = name
				set_summary(Summary.new)
			end

			def add_line(product_code, price, quantity)
				if lines.any? { |l| l.product_code == product_code }
					raise "Already a line for product - #{product_code}"
				end

				signal_event :line_added, product_code: product_code, price: price, quantity: quantity
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
				lines.each { |li| gross_total += li.total }
				summary.calculate_totals(gross_total, tax_rate)
			end

			apply_event :line_added do |args|
				lines << Line.new(args[:product_code], args[:price], args[:quantity])
			end
		end

	end
end