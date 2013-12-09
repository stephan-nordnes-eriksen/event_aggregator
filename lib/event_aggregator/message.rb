module EventAggregator
	class Message
		attr_accessor :message_type
		@message_type = nil
		@data = nil
		def initialize(message_type, data)
			@message_type = message_type
			@data = data
		end
	end
end
