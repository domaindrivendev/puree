module Domain
	module Orders

		class Order < Puree::Domain::AggregateRoot
			identifiable_by :order_no
			has_a :header
			has_many :items

			def initialize(order_no, name)
				@order_no = order_no
				set_header(Header.new(name))

				@next_item_no = 1
			end

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
			def initialize(title)
				@title = title
			end

			def change_title(title)
				signal_event :title_changed, old_title: @title, new_title: title
			end

			apply_event :title_changed do |event|
				@title = event.args[:new_title]
			end
		end

		class Item < Puree::Domain::Entity
			identifiable_by :item_no

			def initialize(item_no, product_name, quantity)
				@item_no = item_no
				@product_name = product_name
				@quantity = quantity
			end

			def change_quantity(quantity)
				signal_event :quantity_changed, item_no: item_no, old_quantity: @quantity, new_quantity: quantity
			end

			apply_event :quantity_changed do |event|
				@quantity = event.args[:new_quantity]
			end
		end

		class OrderFactory < Puree::Domain::AggregateRootFactory
			for_aggregate_root Order
			
			def create(order_no, name)
				signal_event :order_created, order_no: order_no, name: name
			end

			apply_event :order_created do |event|
				Order.new(event.args[:order_no], event.args[:name])
			end
		end

	end
end