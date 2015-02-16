module EventAggregator
	# Public: A module you can include or extend to receive events from
	# the event Aggregator system.
	#
	# Examples
	#
	#   class Foo
	# 		Include Listener
	# 		...
	# 		def initialize()
	# 			...
	# 			event_type_register( "foo", lambda{ puts "bar" } )
	# 		end
	# 		...
	#  	end
	#
	module Listener
		private
		# public: Use to add event types you want to receive. Overwirte existing callback when existing event type is given.
		#
		# event_type 	- A string indicating the event type you want to receive from the event aggregrator. Can actually be anything.
		# callback 		- The method that will be invoked every time this event type is received. Must have: callback.respond_to? :call #=> true
		#
		# Examples
		#
		#   event_type_register("foo", method(:my_class_method))
		#   event_type_register("foo", lambda { puts "foo" })
		#   event_type_register("foo", Proc.new { puts "foo" })
		#
		def event_type_register( event_type, callback )
			Aggregator.register( self, event_type, callback)
		end

		
		# Public: Used to register listener for all event types. Every time a event is published
		# the provided callback will be executed with the event as the content.
		#
		# callback - The method that will be invoked every time this event type is received. Must have: callback.respond_to? :call #=> true
		#
		def event_type_register_all(callback)
			Aggregator.register_all(self, callback)
		end

		# Public: Used to remove a certain type of event from your listening types. Events of this specific type will no longer
		# invoke any callbacks.
		#
		# event_type - A string indicating the event type you no longer want to receive.
		#
		# Examples
		#
		#   event_type_unregister("foo")
		#
		def event_type_unregister( event_type )
			Aggregator.unregister(self, event_type)
		end

		
		# Public: Will unregister the listener from all event types as well as the event_type_register_all.
		# Listener will no longer recieve any callbacks when events of any kind are published.
		#
		def event_type_unregister_all
			Aggregator.unregister_all(self)
		end


		
		# Public: Duplicate some text an arbitrary number of times.
		#
		# event_type - A string indicating the the event type the callback will respond to
		# callback - The callback returning data whenever a event requests the event_type.
		#
		# Excample: 
		# 			listener.producer_register("MultiplyByTwo", lambda{|data| return data*2})
		# 			number = EventAggregator::Event.new("MultiplyByTwo", 3).request
		# 			# => 6
		#
		def producer_register(event_type, callback)
			Aggregator.register_producer(self, event_type, callback)
		end
	end
end
