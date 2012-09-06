require 'puree/domain/aggregate_root'

describe 'an aggregate root' do
	class Test < Puree::Domain::AggregateRoot
	end

	context 'when an instance is created' do
		let(:instance) { Test.create(1, 'foo', 'bar') }
	end
end

