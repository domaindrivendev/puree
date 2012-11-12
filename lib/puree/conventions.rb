module Puree
	
	module Conventions
		def self.resolve_factory_class(aggregate_name)
			class_name = classify(aggregate_name.to_s)
			module_name = pluralize(class_name)

			::Domain.const_get(module_name).const_get(class_name + 'Factory')
		end

		private

		def self.classify(term)
			term.split('_').map { |w| w.capitalize }.join
		end

		def self.pluralize(term)
			term.end_with?('s') ? term : term + 's'
		end
	end

end