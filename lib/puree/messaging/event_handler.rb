module Puree
	module Messaging

		class EventHandler
      attr_reader :event_blocks

      module ClassMethods
        attr_reader :event_blocks

        def on_event(name, &block)
          @event_blocks ||= {}
          @event_blocks[name] = block
        end
      end

      def self.inherited(klass)
        klass.extend(ClassMethods)
      end

      def has_block_for?(name)
        self.class.event_blocks && self.class.event_blocks.has_key?(name)
      end

      def notify(name, args)
        instance_exec(args, &self.class.event_blocks[name])
      end
		end

	end
end