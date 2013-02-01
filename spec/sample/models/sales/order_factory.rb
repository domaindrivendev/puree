module Sales
		
	class OrderFactory < Puree::Domain::AggregateFactory
			
		def create(order_no, name)
			signal_event :order_created, order_no: order_no, name: name
		end

		apply_event :order_created do |args|
			Order.new(args[:order_no], args[:name])
		end
	end

end