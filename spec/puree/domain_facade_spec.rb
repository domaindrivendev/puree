require 'spec_helper'
require 'sample/models/sales'

describe 'A Domain Facade' do
	before(:each) do
		class OrderFacade
			include Puree::DomainFacade
		end
	end

	context 'for a given aggregate' do
		let(:facade) do
			class OrderFacade
				for_aggregate Sales::Order
			end
			OrderFacade.new
		end

		it 'should have access to a Factory for the Aggregate' do
			factory = facade.order_factory
			factory.should be_an_instance_of(Sales::OrderFactory)
		end

		it 'should have access to a Repository for the Aggregate' do
			repository = facade.order_repository
			repository.should be_an_instance_of(Puree::Persistence::EventStoreRepository)
		end
	end

	after(:all) do
		Object.send(:remove_const, 'OrderFacade')
	end
end