module EventAggregator

	# Public: TODO: Could potentially turn this into a module.
	#
	# 	module OtherSingleton
	# 		@index = -1
	# 		@colors = %w{ red green blue }
	# 		def self.change
	# 			@colors[(@index += 1) % @colors.size]
	# 		end
	# 	end
	class Aggregator
		class <<self; private :new; end
		@@pool              = Thread.pool(4)
		@@listeners         = Hash.new{|h, k| h[k] = Hash.new }
		@@listeners_all     = Hash.new
		@@event_translation = Hash.new{|h, k| h[k] = Hash.new }
		@@producers         = Hash.new
		# Public: Register an EventAggregator::Listener to receive
		# 		  a specified event type
		#
		# listener - An EventAggregator::Listener which should receive
		# 			 the events.
		# event_type - The event type to receive. Can be anything except nil.
		# 				 Often it is preferable to use a string eg. "Event Type".
		# callback - The callback that will be executed when events of type equal
		# 				event_type is published. Is executed with event.data as parameter.
		#
		def self.register( listener, event_type, callback )
			raise "Illegal listener" unless listener
			raise "Illegal event_type" if event_type == nil
			raise "Illegal callback" unless callback.respond_to?(:call) || listener.respond_to?(callback)
			if callback.respond_to?(:call)
				@@listeners[event_type][listener] = callback
			else
				@@listeners[event_type][listener] = listener.method(callback)
			end
		end


		# Public: Register an EventAggregator::Listener to receive
		# 		  every single event that is published.
		#
		# listener - An EventAggregator::Listener which should receive
		# 			 the events.
		# callback - The callback that will be executed every time a event is published.
		# 				will execute with the event as parameter.
		#
		def self.register_all( listener, callback )
			raise "Illegal listener" unless listener
			raise "Illegal callback" unless callback.respond_to?(:call) || listener.respond_to?(callback)
			
			if callback.respond_to?(:call)
				@@listeners_all[listener] = callback
			else
				@@listeners_all[listener] = listener.method(callback)
			end
		end

		# Public: Unegister an EventAggregator::Listener to a
		# 		  specified event type. The listener will no
		# 		  longer get events of this type.
		#
		# listener - The EventAggregator::Listener which should no longer receive
		# 			 the events.
		# event_type - The event type to unregister for.
		def self.unregister( listener, event_type )
			@@listeners[event_type].delete(listener)
		end

		# Public: As Unregister, but will unregister listener from all event types.
		#!
		# listener - The listener who should no longer get any events at all,
		# 			 regardless of type.
		def self.unregister_all( listener )
			@@listeners.each do |key,value|
				value.delete(listener)
			end
			@@listeners_all.delete(listener)
		end

		# Public: Will publish the specified event to all listeners
		# 		  who has registered for this event type.
		#
		# event - The event to be distributed to the listeners.
		# async - true => event will be sent async. Default true
		# consisten_data - true => the same object will be sent to all recievers. Default false
		def self.event_publish ( event )
			raise "Invalid event" unless event.respond_to?(:event_type) && event.respond_to?(:data)
			@@listeners[event.event_type].each do |listener, callback|	
				perform_event_job(event.data, callback, event.async, event.consisten_data)
			end
			@@listeners_all.each do |listener,callback|
				perform_event_job(event, callback, event.async, event.consisten_data)
			end
			@@event_translation[event.event_type].each do |event_type_new, callback|
				#TODO: I added event.async and consisten_data here. Add tests for that, and make a new version
				EventAggregator::Event.new(event_type_new, callback.call(event.data), event.async, event.consisten_data).publish
			end
		end


		# Public: Resets the Aggregator to the initial state. This removes all registered listeners.
		# Use EventAggregator::Aggregator.reset before each test when doing unit testing.
		#
		def self.reset
			@@pool.shutdown
    		
			@@listeners         = Hash.new{|h, k| h[k] = Hash.new}
			@@listeners_all     = Hash.new
			@@event_translation = Hash.new{|h, k| h[k] = Hash.new }
			@@producers         = Hash.new
			@@pool              = Thread.pool(4)
		end

		# Public: Will produce another event when a event type is published.
		#
		# event_type - Type of the event that will trigger a new event to be published.
		# event_type_new - The type of the new event that will be published
		# callback=lambda{|data| data} - The callback that will transform the data from event_type to event_type_new. Default: copy.
		#
		def self.translate_event_with(event_type, event_type_new, callback=lambda{|data| data})
			raise "Illegal parameters" if event_type == nil || event_type_new == nil || !callback.respond_to?(:call) || callback.arity != 1 #TODO: The callback.parameters is not 1.8.7 compatible.
			raise "Illegal parameters, equal event_type and event_type_new" if event_type == event_type_new || event_type.eql?(event_type_new)

			@@event_translation[event_type][event_type_new] = callback unless @@event_translation[event_type][event_type_new] == callback
		end

		
		# Public: Registering a producer with the Aggregator. A producer will respond to event requests, a 
		# 			request for a certain piece of data. 
		#
		# event_type - The event type that this callback will respond to.
		# callback - The callback that returns data to the requester. Must have one parameter.
		#
		# Example:
		#
		# 	EventAggregator::Aggregator.register_producer(producer, "GetMultipliedByTwo", lambda{|data| data*2})
		#
		def self.register_producer(producer, event_type, callback)
			raise "Illegal event_type" if event_type == nil
			raise "Illegal callback" unless (callback.respond_to?(:call) && callback.arity == 1) || (producer.respond_to?(callback) && producer.method(callback).arity == 1)
			
			if callback.respond_to?(:call)
				@@producers[event_type] = callback
			else
				@@producers[event_type] = producer.method(callback)
			end
		end
		
		
		# Public: Will remove a producer.
		#
		# event_type - The event type which will no longer respond to event requests.
		#
		def self.unregister_producer(event_type)
			@@producers.delete(event_type)
		end

		
		# Public: Request a piece of information.
		#
		# event - The event that will be requested based on its event type and data.
		#
		# Returns The data provided by a producer registered for this specific event type, or nil.
		#
		def self.event_request(event)
			@@producers[event.event_type] ? @@producers[event.event_type].call(event.data) : nil
		end

		private
		def self.perform_event_job(data, callback, async, consisten_data)
			case [async, consisten_data || data == nil]
			when [true, true]   then @@pool.process{ EventAggregator::EventJob.new.perform(data,       callback) }
			when [true, false]  then @@pool.process{ EventAggregator::EventJob.new.perform(data.clone, callback) }
			when [false, true]  then                 EventAggregator::EventJob.new.perform(data,       callback)
			when [false, false] then                 EventAggregator::EventJob.new.perform(data.clone, callback)
			end
		end
	end
end
