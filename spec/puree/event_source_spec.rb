require 'spec_helper'

describe 'An Object that implements event sourcing' do

  context 'When an instance is created' do
    let(:conference) do
      Conference.new(123, 'Test Conf', 'A test conf')
    end

    it 'should apply the initial state' do
      conference.id.should == 123
      conference.name.should == 'Test Conf'
      conference.description.should == 'A test conf'
    end

    it 'should track the creation event' do
      conference.pending_events.count.should == 1
      event = conference.pending_events.first
      event.name.should == :conference_created
      event.args.should == { id: 123, name: 'Test Conf', description: 'A test conf' }
    end
  end

  context 'When recreated from previous events' do
    let(:conference) do
      conference = Conference.allocate
      conference.replay(ConferenceCreated)
      conference.replay(ConferenceScheduled)
      conference.replay(CalledForProposals)
      conference
    end

    it 'should apply the state changes' do
      conference.id.should == 123
      conference.name.should == 'Test Conf'
      conference.description.should == 'A test conf'
      conference.date.should == ScheduleDate
      conference.accepting_proposals?.should == true
    end
  end

  context 'When commands are applied' do
    let(:conference) do
      conference = Conference.allocate
      conference.replay(ConferenceCreated)

      conference.schedule(ScheduleDate)
      conference.call_for_proposals
      conference
    end

    it 'should apply the state changes' do
      conference.date.should == ScheduleDate
      conference.accepting_proposals?.should == true
    end

    it 'should track the corresponding events' do
      conference.pending_events.count.should == 2

      event = conference.pending_events.first
      event.name.should == :conference_scheduled
      event.args.should == { id: 123, date: ScheduleDate }

      event = conference.pending_events.last
      event.name.should == :called_for_proposals
      event.args.should == { id: 123 }
    end
  end
end