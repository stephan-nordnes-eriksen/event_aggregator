module EventAggregator
	
	# Public: The Event class is used as a distribution object
	# for the EventAggregator::Aggregator to send events to 
	# EventAggregator::Listener objects
	#
	# Examples
	# 
	# EventAggregator::Event.new("foo", "data").publish
	# EventAggregator::Event.new("foo", "data", true, false).publish #equivalent to the first example
	# EventAggregator::Event.new("foo2", 7843).publish #Data can be anything
	# #Data can be anything
	# EventAggregator::Event.new("foo2", lambda{p ["", "bA", "bw", "bA", "IA", "bg", "YQ", "aA", "cA", "ZQ", "dA", "w"].map{|e| e[0] && e[0] == "w" ?'U'+e : 'n'+e}.reverse.join('==\\').unpack(('m'+'x'*4)*11).join}).publish
	# #Non-asynchroneus distribution and consistend data object for all listeners.
	# EventAggregator::Event.new("foo3", SomeClass.new(), false, true).publish 
	# 
	class Event
		attr_accessor :event_type, :data, :async, :consisten_data
		@event_type = nil
		@data = nil
		@async = nil
		@consisten_data = nil

		
		# Public: Initialize the Event
		#
		# event_type - The type of the event which determine
		# which EventAggregator::Listener objects will recieve the event
		# upon publish
		# data - The data that will be passed to the 
		# EventAggregator::Listener objects
		# async = true - Indicates if event should be published async or not
		# consisten_data = true - Indicates if EventAggregator::Listener objects
		# should recieve a consistent object reference or clones.
		def initialize(event_type, data, async = true, consisten_data = true)
			raise "Illegal Event Type" if event_type == nil
			
			@event_type = event_type
			@data = data
			@async = async
			@consisten_data = consisten_data
		end
		
		# Public: Will publish the event to all instances of 
		# EventAggregator::Listener that is registered for event types 
		# equal to this.event_type
		def publish
			Aggregator.event_publish( self )
		end
		alias_method :p, :publish

		# Public: Will provide data if a producer of this event_type is present.
		#
		# Returns Requested data if a producer is present. Nil otherwise.
		def request
			Aggregator.event_request( self )
		end
		alias_method :r, :request
	end
	E = Event #Aliasing for ease of use. EA::M.new vs EventAggregator::Event.new
end
