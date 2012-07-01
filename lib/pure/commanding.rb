require 'pure/eventing/event_store_repository'

module Pure
	module Commanding
		module ClassMethods

			attr_reader :aggregate_root_classes

			def for_aggregate_root(aggregate_root_class)
				@aggregate_root_classes ||= []
				@aggregate_root_classes << aggregate_root_class
			end
		end

		def self.included(klass)
			klass.extend(ClassMethods)
		end

		def method_missing(method, *args, &block)
			self.class.aggregate_root_classes.each do |klass|
				name = klass.name.split('::').last
				underscored_name = name.gsub(/(.)([A-Z])/, '\1_\2').downcase

				if method.to_s == "create_#{underscored_name}"
					return klass.create(args[0])
				elsif method.to_s == "#{underscored_name}_repository"
					return Eventing::EventStoreRepository.for_aggregate_root(klass)
				end
			end

			super.method_missing(method, args, block)
		end
	end
end