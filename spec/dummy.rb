class Conference < Puree::EventSource
  attr_reader :id, :name, :description, :date

  def initialize(id, name, description=nil)
    raise ArgumentError.new("id required") if id.nil?
    raise ArgumentError.new("name required") if id.nil?

    signal_event :conference_created,
      id: id,
      name: name,
      description: description
  end

  def schedule(date)
    thirty_days = (60 * 60 * 24 * 30)
    raise ArgumentError.new('Thirty days notice required') if date < (Time.now + thirty_days)

    signal_event :conference_scheduled,
      id: @id,
      date: date
  end

  def call_for_proposals
    raise RuntimeError("Not yet scheduled") if date.nil?

    signal_event :called_for_proposals, id: @id
  end

  def accepting_proposals?
    @status == :accepting_proposals
  end

  apply_event :conference_created do |args|
    @id = args[:id]
    @name = args[:name]
    @description = args[:description]
    @status = :draft
  end

  apply_event :conference_scheduled do |args|
    @date = args[:date]
  end

  apply_event :called_for_proposals do |args|
    @status = :accepting_proposals
  end
end

class TestSubscriber < Puree::Messaging::Subscriber
  attr_reader :notifications

  def initialize
    @notifications = {}
  end

  on_event :conference_created do |args|
    @notifications[:conference_created] = args
  end

  on_event :conference_scheduled do |args|
    @notifications[:conference_scheduled] = args
  end

  on_event :called_for_proposals do |args|
    @notifications[:called_for_proposals] = args
  end
end