module Puree
	module EventBus

		class MemoryEventBus
			def initialize
				@observers = []
			end

			def register(observer)
				@observers << observer
			end

			def publish(event)
				@observers.each do |observer|
					if observer.event_names.include?(event.name)
						observer.notify(event)
					end
				end 
			end
			
		end

	end
end