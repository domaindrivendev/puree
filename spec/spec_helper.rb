require 'puree'

require 'dummy'
require 'fakes'

# Test constants
ScheduleDate = Time.now + (60 * 60 * 24 * 31)
ConferenceCreated = Puree::Event.new(:conference_created, id: 123, name: 'Test Conf', description: 'A test conf')
ConferenceScheduled = Puree::Event.new(:conference_scheduled, id: 123, date: ScheduleDate)
CalledForProposals = Puree::Event.new(:called_for_proposals, id: 123)