module Puree
	
	module Conventions
		
		def get_aggregate_name(root_class)
			underscore(short_name(root_class))
		end

		def get_factory_class(root_class)
			module_names = root_class.name.split('::')
			module_names.pop
			
			enclosing_module = Object
			module_names.each { |mn| enclosing_module = enclosing_module.const_get(mn) } 

			factory_short_name = "#{short_name(root_class)}Factory"
			enclosing_module.const_get(factory_short_name)
		end

		private

		def short_name(klass)
			klass.name.split('::').last
		end

		def underscore(word)
	    word.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').downcase
		end
	end

end