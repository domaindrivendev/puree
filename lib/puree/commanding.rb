module Puree

	module Commanding
		module ClassMethods
			include Puree::Conventions
			attr_reader :factory_classes

			def orchestrates(aggregate_root_class)
				@factory_classes ||= {}
				@factory_classes[aggregate_nickname(aggregate_root_class)] = aggregate_root_factory_class(aggregate_root_class)
			end
		end

		def self.included(klass)
			klass.extend(ClassMethods)
		end

		def method_missing(method, *args, &block)
			method_name = method.to_s

			# factory accessors
			if method_name.end_with?('_factory')
				aggregate_nickname = method_name[0..-9]
				factory = get_factory(aggregate_nickname)
				return factory unless factory.nil?
			end

			# repository accessors
			if method_name.end_with?('_repository')
				aggregate_nickname = method_name[0..-12]
				factory = get_factory(aggregate_nickname)
				unless factory.nil?
					return get_repository(aggregate_nickname, factory)
				end
			end

			super.method_missing(method, *args, &block)
		end

		def get_factory(aggregate_nickname)
			factory_classes = self.class.factory_classes

			@factories ||= {}
			if @factories[aggregate_nickname].nil? and factory_classes.has_key?(aggregate_nickname)
				id_generator = Puree.config.id_generator
				@factories[aggregate_nickname] = factory_classes[aggregate_nickname].new(id_generator)
			end
			@factories[aggregate_nickname]
		end

		def get_repository(aggregate_name, factory)
			@repositories ||= {}
			if @repositories[aggregate_name].nil?
				event_store = Puree.config.event_store
				event_bus = Puree.config.event_bus
				@repositories[aggregate_name] = Puree::Persistence::EventStoreRepository.new(factory, event_store, event_bus)
			end
			@repositories[aggregate_name]
		end
	end
end