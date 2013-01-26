require 'puree/messaging/sync_message_bus'

describe 'A Syncronous Message Bus' do
  let(:message_bus) { Puree::Messaging::SyncMessageBus.new }

  context 'with a comand handler registered' do
    before(:each) do
      class OrderCommandHandler < Puree::Messaging::CommandHandler
        on_command :order_created do |command|
          @command_received = true
        end

        def has_received_the_command?
          @command_received
        end
      end

      @handler = OrderCommandHandler.new
      message_bus.register_command_handler(@handler)
    end

    it 'should route to the corresponding handler when the command is sent' do
      message_bus.send_command :order_created, order_no: 1
      @handler.should have_received_the_command
    end
  end
end