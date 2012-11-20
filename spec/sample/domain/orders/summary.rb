module Domain
	module Orders

		class Summary < Puree::Domain::Entity
			def initialize
				@gross_total = 0.0
				@tax_rate = 0.0
				@tax_amount = 0.0
				@net_total = 0.0
			end

			def calculate_total(gross_total, tax_rate)
				tax_amount = gross_total * tax_rate
				net_total = gross_total + tax_amount

				signal_event :total_calculated,
					gross_total: gross_total,
					tax_rate: tax_rate,
					tax_amount: tax_amount,
					net_total: net_total
			end

			apply_event :total_calculated do |event|
				@net_total = event.args[:net_total]
			end
		end

	end
end