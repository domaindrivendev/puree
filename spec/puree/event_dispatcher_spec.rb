require 'spec_helper'

describe 'An EventDispatcher, ' do
  let(:dispatcher) { Puree::EventDispatcher.new }

  context 'with registered listeners, ' do
    before(:each) do
      @listener1 = TestEventListener.new
      @listener2 = TestEventListener.new

      dispatcher.register(@listener1)
      dispatcher.register(@listener2)
    end

    context 'when an event is dispatched, ' do
      before(:each) do
        dispatcher.dispatch(ConferenceCreated)
        dispatcher.dispatch(ConferenceScheduled)
        dispatcher.dispatch(CalledForProposals)
      end

      it 'should notify any listeners that subscribe to the event' do
        @listener1.notifications.length.should == 3
        @listener1.notifications.should have_key(:conference_created)

        @listener2.notifications.length.should == 3
        @listener2.notifications.should have_key(:conference_created)
      end
    end
  end
end