module Puree
  module Messaging

    class CommandHandler
      include ::Puree::DomainFacade

      module ClassMethods
        attr_reader :command_blocks

        def on_command(name, &block)
          @command_blocks ||= {}
          @command_blocks[name] = block
        end
      end

      def self.inherited(klass)
        klass.extend(ClassMethods)
      end

      def has_block_for?(name)
        self.class.command_blocks && self.class.command_blocks.has_key?(name)
      end

      def execute(name, args)
        instance_exec(args, &self.class.command_blocks[name])
      end
    end

  end
end