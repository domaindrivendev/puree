require 'spec_helper'

describe 'A Repository' do
  let(:event_store) { FakeEventStore.new }
  let(:event_bus) { FakeEventBus.new }
  let(:repository) do
    Puree::Repository.for(Conference,
      lambda { |conference| conference.id },
      event_store,
      event_bus)
  end

  context 'When an event source is added' do
    before(:each) do
      conference = Conference.new(123, 'Test Conf', 'A test conf')
      conference.schedule(ScheduleDate)

      repository.add(conference)
    end

    it 'should persist tracked events to the event store' do
      stream = event_store.get_events('Conference_123')
      stream.count.should == 2

      event = stream.first
      event.name.should == :conference_created
      event.args.should == { id: 123, name: 'Test Conf', description: 'A test conf' }

      event = stream.last
      event.name.should == :conference_scheduled
      event.args.should == { id: 123, date: ScheduleDate }
    end

    it 'should publish tracked events to the event bus ' do
      event_bus.publications.count.should == 2
    end
  end

  context 'When an event source is retreived' do
    let(:conference) do
      event_store.add_events('Conference_123', [ ConferenceCreated, ConferenceScheduled, CalledForProposals ])
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