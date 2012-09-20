module Puree
	module EventBus

		class MemoryEventBus
			def initialize
				@subscribers = []
			end

			def register(subscriber)
				@subscribers << subscriber
			end

			def publish(event)
				@subscribers.each do |subscriber|
					if subscriber.event_names.include?(event.name)
						subscriber.notify(event)
					end
				end 
			end
			
		end

	end
end