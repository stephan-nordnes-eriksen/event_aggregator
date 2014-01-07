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
		@@listeners_all = Hash.new

		# Public: Register an EventAggregator::Listener to receive
		# 		  a specified message type
		#
		# listener - An EventAggregator::Listener which should receive
		# 			 the messages.
		# message_type - The message type to receive. Can be anything except nil.
		# 				 Often it is preferable to use a string eg. "Message Type".
		# callback - The callback that will be executed when messages of type equal
		# 				message_type is published. Is executed with message.data as parameter.
		#
		def self.register( listener, message_type, callback )
			raise "Illegal callback" unless callback.respond_to?(:call)
			@@listeners[message_type] << [listener, callback] unless ! (listener.class < EventAggregator::Listener) || @@listeners[message_type].include?(listener)
		end

		
		# Public: Register an EventAggregator::Listener to receive
		# 		  every single message that is published.
		#
		# listener - An EventAggregator::Listener which should receive
		# 			 the messages.
		# callback - The callback that will be executed every time a message is published.
		# 				will execute with the message as parameter.
		#
		# Returns the duplicated String.
		def self.register_all( listener, callback )
			raise "Illegal callback" unless callback.respond_to?(:call)
			@@listeners_all[listener] = callback unless ! (listener.class < EventAggregator::Listener) || @@listeners_all.include?(listener)
		end

		# Public: Unegister an EventAggregator::Listener to a
		# 		  specified message type. The listener will no
		# 		  longer get messages of this type.
		#
		# listener - The EventAggregator::Listener which should no longer receive
		# 			 the messages.
		# message_type - The message type to unregister for.
		def self.unregister( listener, message_type )
			@@listeners[message_type].delete_if{|value| value[0] == listener}
		end

		# Public: As Unregister, but will unregister listener from all message types.
		#!
		# listener - The listener who should no longer get any messages at all,
		# 			 regardless of type.
		def self.unregister_all( listener )
			@@listeners.each do |e|
				e[1].delete_if{|value| value[0] == listener}
			end
			@@listeners_all.delete(listener)
		end

		# Public: Will publish the specified message to all listeners
		# 		  who has registered for this message type.
		#
		# message - The message to be distributed to the listeners.
		# async - true => message will be sent async. Default true
		# consisten_data - true => the same object will be sent to all recievers. Default false
		def self.message_publish ( message )
			raise "Invalid message" unless message.respond_to?(:message_type) && message.respond_to?(:data)
			@@listeners[message.message_type].each do |l|
				if l[1].respond_to? :call
					case [message.async, message.consisten_data]
					when [true, true]   then EventAggregator::MessageJob.new.async.perform(message.data,       l[1])
					when [true, false]  then EventAggregator::MessageJob.new.async.perform(message.data.clone, l[1])
					when [false, true]  then EventAggregator::MessageJob.new.perform(      message.data,       l[1])
					when [false, false] then EventAggregator::MessageJob.new.perform(      message.data.clone, l[1])
					end
				end
			end
			#TODO: Consider refactoring this, and the above, into a separate, hopefully private, method:
			@@listeners_all.each do |listener,callback|
				case [message.async, message.consisten_data]
				when [true, true]   then EventAggregator::MessageJob.new.async.perform(message,       callback)
				when [true, false]  then EventAggregator::MessageJob.new.async.perform(message.clone, callback)
				when [false, true]  then EventAggregator::MessageJob.new.perform(      message,       callback)
				when [false, false] then EventAggregator::MessageJob.new.perform(      message.clone, callback)
				end
			end
		end


		# Public: Resets the Aggregator to the initial state. This removes all registered listeners. 
		# Use EventAggregator::Aggregator.reset before each test when doing unit testing.
		#
		def self.reset
			@@listeners = Hash.new{|h, k| h[k] = []}
			@@listeners_all = Hash.new			
		end
	end
end
