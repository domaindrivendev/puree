require 'spec_helper'

describe 'A class with Commanding behavior' do
	before(:each) do
		class OrderController
			include Puree::Commanding
		end
	end

	context 'that specifies a target Aggregate' do
		let(:controller) do
			
			# Use fake classes namespaced according to the Puree convention
			module Domain
				module Orders
					class Order < Puree::Domain::AggregateRoot
					end

					class OrderFactory < Puree::Domain::AggregateRootFactory
						for_aggregate_root Order
					end
				end
			end

			class OrderController
				for_aggregate :order
			end

			OrderController.new
		end

		it 'should have access to a Factory for the Aggregate Root, discovered by convention' do
			factory = controller.order_factory
			factory.should be_an_instance_of(Domain::Orders::OrderFactory)
		end

		it 'should have access to a Repository for the Aggregate Root, discovered by convention' do
			repository = controller.order_repository
			repository.should be_an_instance_of(Puree::Persistence::EventStoreRepository)
			repository.instance_variable_get(:@event_store).should be_an_instance_of(Puree::Persistence::MemoryEventStore)
			repository.instance_variable_get(:@event_bus).should be_an_instance_of(Puree::EventBus::MemoryEventBus)
		end
	end

	after(:all) do
		Domain::Orders.send(:remove_const, 'Order')
		Domain::Orders.send(:remove_const, 'OrderFactory')
		Domain.send(:remove_const, 'Orders')
		Object.send(:remove_const, 'Domain')
		Object.send(:remove_const, 'OrderController')
	end
end