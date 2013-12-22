module EventAggregator
	
	# Public: The Message class is used as a distribution object
	# for the EventAggregator::Aggregator to send messages to 
	# EventAggregator::Listener objects
	#
	# Examples
	# 
	# EventAggregator::Message.new("foo", "data").publish
	# EventAggregator::Message.new("foo", "data", true, false).publish #equivalent to the first example
	# EventAggregator::Message.new("foo2", 7843).publish #Data can be anything
	# #Data can be anything
	# EventAggregator::Message.new("foo2", lambda{p ["", "cg", "bw", "eA", "YQ", "A"].map{|e| e[0] && e[0] =="A" ?'a'+e : 'n'+e}.reverse.join('==\\').unpack(('m'+'x'*4)*5).join}).publish
	# #Non-asynchroneus distribution and consistend data object for all listeners.
	# EventAggregator::Message.new("foo3", SomeClass.new(), false, true).publish 
	# 
	class Message
		attr_accessor :message_type, :data
		@message_type = nil
		@data = nil
		@async = nil
		@consisten_data = nil

		
		# Public: Initialize the Message
		#
		# message_type - The type of the message which determine
		# which EventAggregator::Listener objects will recieve the message
		# upon publish
		# data - The data that will be passed to the 
		# EventAggregator::Listener objects
		# async = true - Indicates if message should be published async or not
		# consisten_data = false - Indicates if EventAggregator::Listener objects
		# should recieve a consistent object reference or clones.
		def initialize(message_type, data, async = true, consisten_data = false)
			raise "Illegal Message Type" if message_type == nil
			
			@message_type = message_type
			@data = data
			@async = async
			@consisten_data = consisten_data
		end
		
		# Public: Will publish the message to all instances of 
		# EventAggregator::Listener that is registered for message types 
		# equal to this.message_type
		def publish
			Aggregator.message_publish( self, async, consisten_data )
		end
	end
end
