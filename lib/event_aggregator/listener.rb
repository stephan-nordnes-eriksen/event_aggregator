module EventAggregator
	# Public: A module you can include or extend to receive messages from
	# the event Aggregator system.
	#
	# Examples
	#
	#   class Foo
	# 		Include Listener
	# 		...
	# 		def initialize()
	# 			...
	# 			message_type_register( "foo", lambda{ puts "bar" } )
	# 		end
	# 		...
	#  	end
	#
	module Listener
		def receive_message( message )
			m = event_listener_listens_to[message.message_type]

			m.call(message.data) if m.respond_to? :call #Should not need the check here, however who knows what kind of conurrency issues we might have.
			#This will probably become hotpath, so having the extra check can be problematic.
		end

		private
		def event_listener_listens_to
			@event_listener_listens_to ||= Hash.new
		end
		# public: Use to add message types you want to receive. Overwirte existing callback when existing message type is given.
		#
		# message_type 	- A string indicating the message type you want to receive from the event aggregrator. Can actually be anything.
		# callback 		- The method that will be invoked every time this message type is received. Must have: callback.respond_to? :call #=> true
		#
		# Examples
		#
		#   message_type_register("foo", method(:my_class_method))
		#   message_type_register("foo", lambda { puts "foo" })
		#   message_type_register("foo", Proc.new { puts "foo" })
		#
		def message_type_register( message_type, callback )
			event_listener_listens_to[message_type] = callback #unless event_listener_listens_to[message_type] #It makes more sence to overwrite in the case it already exists.
			Aggregator.register( self, message_type )
		end

		# Public: Used to remove a certain type of message from your listening types. Messages of this specific type will no longer
		# invoke any callbacks.
		#
		# message_type -A string indicating the message type you no longer want to receive.
		#
		# Examples
		#
		#   message_type_unregister("foo")
		#
		def message_type_unregister( message_type )
			event_listener_listens_to[message_type] = nil
			Aggregator.unregister(self, message_type)
		end
	end
end
