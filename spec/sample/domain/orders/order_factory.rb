module Domain
	module Orders

		class OrderFactory < Puree::Domain::AggregateRootFactory
			for_aggregate_root Order
			
			def create(name)
				signal_event :order_created, order_no: next_order_no, name: name
			end

			apply_event :order_created do |event|
				Order.new(event.args[:order_no], event.args[:name])
			end
		end

	end
end