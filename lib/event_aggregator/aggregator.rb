module EventAggregator
	class Aggregator
		@@listeners = Hash.new{|h, k| h[k] = []}

		def self.register( listener, message_type )
			@@listeners[message_type] << listener unless ! (listener.class < EventAggregator::Listener) || @@listeners[message_type].include?(listener)
		end

		def self.unregister( listener, message_type )
			@@listeners[message_type].delete listener
		end

		def self.message_publish ( message )
			#TODO: Figure out behaviour when not recieving a correct message. Maybe "do nothing" is the right thing.
			return "Not a valid message" unless message.is_a? EventAggregator::Message

			@@listeners[message.message_type].each do |l|
				l.recieve_message message
			end
		end
	end
end
