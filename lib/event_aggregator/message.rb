module EventAggregator
	class Message
		attr_accessor :message_type, :data
		@message_type = nil
		@data = nil
		@async = nil
		@consisten_data = nil

		
		# Public: Initialize the Message
		#
		# message_type - The type of the message which determine
		# which listeners will recieve the message
		# data -The data that will be passed to the listeners
		# async = true - Indicates if message should be published async or not
		# consisten_data = false - Indicates if message listeners should recieve
		# the same object reference
		def initialize(message_type, data, async = true, consisten_data = false)
			raise "Illegal Message Type" if message_type == nil
			
			@message_type = message_type
			@data = data
			@async = async
			@consisten_data = consisten_data
		end
		
		# Public: Will publish the message to all that 
		# 		  listens of this message_type
		def publish
			Aggregator.message_publish( self, async, consisten_data )
		end
	end
end
