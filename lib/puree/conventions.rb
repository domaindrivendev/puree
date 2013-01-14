module Puree
	
	module Conventions
		
		def aggregate_nickname(aggregate_root_class)
			underscore(class_short_name(aggregate_root_class))
		end

		def aggregate_root_factory_class(aggregate_root_class)
			module_names = aggregate_root_class.name.split('::')
			module_names.pop
			
			enclosing_module = Object
			module_names.each { |mn| enclosing_module = enclosing_module.const_get(mn) } 

			factory_class_name = "#{class_short_name(aggregate_root_class)}Factory"
			enclosing_module.const_get(factory_class_name)
		end

		private

		def class_short_name(klass)
			klass.name.split('::').last
		end

		def underscore(word)
	    word.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').downcase
		end
	end

end