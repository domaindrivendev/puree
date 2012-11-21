module Domain
	module Orders

		class Summary < Puree::Domain::Entity
			def initialize
				@gross_total = 0.0
				@tax_rate = 0.0
				@tax_amount = 0.0
				@net_total = 0.0
			end

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

	end
end