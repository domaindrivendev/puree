require 'puree/messaging/sync_message_bus'

describe 'A Syncronous Message Bus' do
  let(:message_bus) { Puree::Messaging::SyncMessageBus.new }

  context 'with a comand handler registered' do
    before(:each) do
      class OrderCommandHandler < Puree::Messaging::CommandHandler
        on_command :create_order do |command|
          @command_received = true
        end

        def has_received_the_command?
          @command_received
        end
      end

      @handler = OrderCommandHandler.new
      message_bus.register_command_handler(@handler)
    end

    it 'should execute the corresponding block when a command is sent' do
      message_bus.send_command :create_order, order_no: 1
      @handler.should have_received_the_command
    end
  end

  context 'with multiple event handlers registered' do
    before(:each) do
      class OrderEventHandler < Puree::Messaging::EventHandler
        on_event :order_created do |command|
          @event_received = true
        end

        def has_received_the_event?
          @event_received
        end
      end

      @handler1 = OrderEventHandler.new
      @handler2 = OrderEventHandler.new
      message_bus.register_event_handler(@handler1)
      message_bus.register_event_handler(@handler2)
    end

    it 'should execute all corresponding blocks when an event is published' do
      message_bus.publish_event :order_created, order_no: 1
      @handler1.should have_received_the_event
      @handler2.should have_received_the_event
    end
  end

  after(:all) do
    Object.send(:remove_const, :OrderCommandHandler)
    Object.send(:remove_const, :OrderEventHandler)
  end
end