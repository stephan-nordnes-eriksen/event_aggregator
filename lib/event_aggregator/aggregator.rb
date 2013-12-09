module EventAggregator
	class Aggregator
		@@listeners = Hash.new([])

		@@message_types = Hash.new

		def self.register( listener, message_type )#TODO: Maybe redesign this to get the types of messages this listens for, and put them into a hash with lists of all listeners for that message.
			#@@listeners << listener
			@@listeners[message_type] << listener unless @@listeners[message_type].include?(listener)
		end

		def self.unregister( listener, message_type )
			@@listeners[message_type].delete listener
		end

		def self.message_publish ( message )
			return "Not a valid message" unless message.is_a? EventMessage

			@@listeners[message.message_type].each do |l|
				#l.recieve_message if l.want message
				l.recieve_message message
			end
		end

		def self.register_message_type(message_type)
			@@message_types[message_types] = [] unless @@message_types[message_types]
		end
	end
end
