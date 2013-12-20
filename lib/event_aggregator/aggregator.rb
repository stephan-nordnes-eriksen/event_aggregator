module EventAggregator

	# Public: TODO: Could potentially turn this into a module.
	#
	# 	module OtherSingleton
	# 		@index = -1
	# 		@colors = %w{ red green blue }
	# 		def self.change
	# 			@colors[(@index += 1) % @colors.size]
	# 		end
	# 	end
	class Aggregator
		class <<self; private :new; end

		@@listeners = Hash.new{|h, k| h[k] = []}
		
		# Public: Register an EventAggregator::Listener to recieve
		# 		  a specified message type
		#
		# listener - An EventAggregator::Listener which should recieve 
		# 			 the messages.
		# message_type -The message type to recieve. Can be anything except nil.
		# 				 Often it is preferable to use a string eg. "Message Type".
		#
		# Returns True if listener is added. #TODO: Verify this
		def self.register( listener, message_type, callback )
			@@listeners[message_type] << [listener, callback] unless ! (listener.class < EventAggregator::Listener) || @@listeners[message_type].include?(listener)
		end
		
		# Public: Unegister an EventAggregator::Listener to a 
		# 		  specified message type. The listener will no
		# 		  longer get messages of this type.
		# 
		# listener - The EventAggregator::Listener which should no longer recieve 
		# 			 the messages.
		# message_type - The message type to unregister for.
		#
		# Returns True if listener is no longer recieving this message type. #TODO: Verify this
		def self.unregister( listener, message_type )
			@@listeners[message_type].delete_if{|value| value[0] == listener} 
		end
		
		# Public: As Unregister, but will unregister listener from all message types.
		#
		# listener -The listener who should no longer get any messages at all, 
		# 			 regardless of type.
		def self.unregister_all( listener )
			@@listeners.each do |e|
				e[1].delete_if{|value| value[0] == listener}
			end
		end
		
		# Public: Will publish the specified message to all listeners
		# 		  who has registered for this message type.
		#
		# message -The message to be distributed to the listeners.
		def self.message_publish ( message )
			raise "Invalid message" unless message.is_a? EventAggregator::Message

			@@listeners[message.message_type].each do |l|
				l[1].call(message.data) if l[1].respond_to? :call
				#l[0].receive_message message
			end
		end
	end
end
