module Puree

	module DomainFacade
	
		module ClassMethods
			include Puree::Conventions

			attr_reader :factory_classes

			def for_aggregate(root_class)
				aggregate_name = get_aggregate_name(root_class)

				@factory_classes ||= {}
				@factory_classes[aggregate_name] = get_factory_class(root_class) 
			end
		end

		def self.included(klass)
			klass.extend(ClassMethods)
		end

		def method_missing(method, *args, &block)
			method_name = method.to_s

			# factory accessors
			if method_name.end_with?('_factory')
				aggregate_name = method_name[0..-9]
				factory = get_factory(aggregate_name)
				return factory unless factory.nil?
			end

			# repository accessors
			if method_name.end_with?('_repository')
				aggregate_name = method_name[0..-12]
				factory = get_factory(aggregate_name)
				unless factory.nil?
					return get_repository(aggregate_name, factory)
				end
			end

			super(method, *args, &block)
		end

		private

			def get_factory(aggregate_name)
				factory_classes = self.class.factory_classes

				@factories ||= {}
				if @factories[aggregate_name].nil? and factory_classes.has_key?(aggregate_name)
					@factories[aggregate_name] = factory_classes[aggregate_name].new
				end
				@factories[aggregate_name]
			end

			def get_repository(aggregate_name, factory)
				@repositories ||= {}
				if @repositories[aggregate_name].nil?
					event_store = Puree.config.event_store
					message_bus = Puree.config.message_bus
					@repositories[aggregate_name] = Puree::Persistence::EventStoreRepository.new(factory, event_store, message_bus)
				end
				@repositories[aggregate_name]
			end
	end

end