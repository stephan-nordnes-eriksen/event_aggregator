module EventAggregator
	class Aggregator
		@@listeners = Hash.new{|h, k| h[k] = []}

		def self.register( listener, message_type )
			@@listeners[message_type] << listener unless ! (listener.class < EventAggregator::Listener) || @@listeners[message_type].include?(listener)
		end

		def self.unregister( listener, message_type )
			@@listeners[message_type].delete listener
		end
		def self.unregister_all( listener )
			@@listeners.each do |e|
				e[1].delete(listener)
			end
		end
		def self.message_publish ( message )
			raise "Invalid message" unless message.is_a? EventAggregator::Message

			@@listeners[message.message_type].each do |l|
				l.receive_message message
			end
		end
	end
end
