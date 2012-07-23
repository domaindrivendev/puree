require 'pure/repositories/event_store_repository'

module Pure
	module Commanding
		module ClassMethods

	  	attr_reader :aggregate_root_klasses

			def for_aggregate_root(klass)
        @aggregate_root_klasses ||= []
        @aggregate_root_klasses << klass
			end
		end

		def self.included(klass)
			klass.extend(ClassMethods)
		end

		def method_missing(method, *args, &block)
			self.class.aggregate_root_klasses.each do |klass|
				name = klass.name.split('::').last
				underscored_name = name.gsub(/(.)([A-Z])/, '\1_\2').downcase

				if method.to_s == "create_#{underscored_name}"
          id = Pure.config.id_generator.next_id(klass.name)
					return klass.create(id, args[0])
				elsif method.to_s == "#{underscored_name}_repository"
					return Repositories::EventStoreRepository.for_aggregate_root(klass)
				end
			end

			super.method_missing(method, args, block)
		end
	end
end