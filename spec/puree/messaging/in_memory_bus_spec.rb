require 'spec_helper'

describe 'An InMemoryBus' do
  let(:bus) { Puree::Messaging::InMemoryBus.instance }

  context 'with registered subscribers' do
    before(:each) do
      @subscriber1 = TestSubscriber.new
      @subscriber2 = TestSubscriber.new

      bus.subscribe(@subscriber1)
      bus.subscribe(@subscriber2)
    end

    context 'when events are published' do
      before(:each) do
        bus.publish(ConferenceCreated)
        bus.publish(ConferenceScheduled)
        bus.publish(CalledForProposals)
      end

      it 'should notify all subscribers' do
        @subscriber1.notifications.length.should == 3
        @subscriber1.notifications.should have_key(:conference_created)

        @subscriber2.notifications.length.should == 3
        @subscriber2.notifications.should have_key(:conference_created)
      end
    end
  end
end