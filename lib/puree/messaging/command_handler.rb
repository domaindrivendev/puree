module Puree
  module Messaging

    class CommandHandler

      module ClassMethods
        def on_command(name, &block)
        end
      end

      def self.inherited(klass)
        klass.extend(ClassMethods)
      end
    end

  end
end