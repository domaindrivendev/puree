require 'spec_helper'

describe 'A Repository, ' do
  let(:event_store) { FakeEventStore.new }
  let(:event_dispatcher) { FakeEventDispatcher.new }
  let(:repository) do
    Puree::Repository.for(
      Conference,
      event_store,
      event_dispatcher)
  end

  context 'When an Event-sourced aggregate is added, ' do
    before(:each) do
      conference = Conference.new(123, 'Test Conf', 'A test conf')
      conference.schedule(ScheduleDate)

      repository.add(conference)
    end

    it 'should persist tracked events to the event store' do
      stream = event_store.get_events_for('Conference_123')
      stream.count.should == 2

      event = stream.first
      event.name.should == :conference_created
      event.args.should == { id: 123, name: 'Test Conf', description: 'A test conf' }

      event = stream.last
      event.name.should == :conference_scheduled
      event.args.should == { id: 123, date: ScheduleDate }
    end

    it 'should dispatch tracked events to interested listeners' do
      event_dispatcher.dispatched_events.count.should == 2
    end
  end

  context 'When an Event-sourced aggregate is retrieved, ' do
    let(:conference) do
      event_store.create_stream('Conference_123', [ ConferenceCreated ])
      event_store.append_events_to('Conference_123', [ ConferenceScheduled, CalledForProposals ])
      repository.find_by(123)
    end

    it 'should replay all previous events' do
      conference.id.should == 123
      conference.name.should == 'Test Conf'
      conference.description.should == 'A test conf'
      conference.accepting_proposals?.should be true
    end
  end
end