module EventAggregator
	# Public: A module you can include or extend to recieve messages from
	# the event Aggregator system.
	#
	# Examples
	#
	#   class Foo
	# 		Include Listener
	# 		...
	# 		def initialize()
	# 			...
	# 			message_type_to_recieve_add( "foo", lambda{ puts "bar" } )
	# 		end
	# 		...
	#  	end
	#
	module Listener

		#event_listener_listens_to = Hash.new() #This actually sets Listener.event_listener_listens_to = Hash.new, not the instance


		# Public: This is the callback method when the module is extended.
		# Using this to setup the last few things before the event listener can start.
		#
		# base - The class object for the class extening the Listener module
		#
		# Returns nil
		def self.extended(base)
			# Initialize module.
			#		add_auto_register_procedure(base) #Depricated now, but it is utterly awesome that you can do this.
		end

		# Public: This is the callback method when the module is included.
		# Using this to setup the last few things before the event listener can start.
		#
		# base - The class object for the class including the Listener module
		#
		# Returns nil
		def self.included(base)
			# Initialize module.
			#		add_auto_register_procedure(base) #Depricated now, but it is utterly awesome that you can do this.
		end


		# Public: DEPRICATED: Adding extra initialize to the class so that we make sure new objects are added to the EventAggregators registry.
		# This whole hack-deal is possibly not nescessary. Can be omited with a simple "register" when you add a new "recieve message_type"
		#
		# base - The class object for the class including the Listener module
		#
		# Returns nil
		def self.add_auto_register_procedure(base)
			base.class_eval do
				# back up method's name
				alias_method :old_initialize, :initialize

				# replace the old method with a new version which adds the Aggregator registry
				def initialize(*args)
					Aggregator.register self
					old_initialize(*args)
				end
			end
		end

		def recieve_message( message )
			m = event_listener_listens_to[message.message_type]

			m.call(message.data) if m.respond_to? :call #Should not need the check here, however who knows what kind of conurrency issues we might have.
			#This will probably become hotpath, so having the extra check can be problematic.
		end

		private
		def event_listener_listens_to
			@event_listener_listens_to ||= Hash.new
		end
		# public: Use to add message types you want to recieve. Overwirte existing callback when existing message type is given.
		#
		# message_type 	- A string indicating the message type you want to recieve from the event aggregrator. Can actually be anything.
		# callback 		- The method that will be invoked every time this message type is recieved. Must have: callback.respond_to? :call #=> true
		#
		# Examples
		#
		#   message_type_to_recieve_add("foo", method(:my_class_method))
		#   message_type_to_recieve_add("foo", lambda { puts "foo" })
		#   message_type_to_recieve_add("foo", Proc.new { puts "foo" })
		#
		def message_type_to_recieve_add( message_type, callback )
			event_listener_listens_to[message_type] = callback #unless event_listener_listens_to[message_type] #It makes more sence to overwrite in the case it already exists.
			Aggregator.register( self, message_type )
		end

		# Public: Used to remove a certain type of message from your listening types. Messages of this specific type will no longer
		# invoke any callbacks.
		#
		# message_type -A string indicating the message type you no longer want to recieve.
		#
		# Examples
		#
		#   message_type_to_recieve_remove("foo")
		#
		def message_type_to_recieve_remove( message_type )
			event_listener_listens_to[message_type] = nil
			Aggregator.unregister(self, message_type)
		end
	end
end
