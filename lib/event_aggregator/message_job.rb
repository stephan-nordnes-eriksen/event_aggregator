module EventAggregator
	
	# Public: MessageJob is a class used by the EventAggregator::Aggregator
	# for processing message distribution.
	#
	class MessageJob
		
		# Public: Duplicate some text an arbitrary number of times.
		#
		# data - The data that will be sent to the callback, originating 
		# from a message.
		# callback - The callback that will be processed with the data as 
		# a parameter
		def perform(data, callback)
			begin
				callback.call(data)
			rescue Exception => e
				STDERR.puts e.message
				STDERR.puts e.backtrace
				STDERR.puts "------------"
				if callback.respond_to?(:source_location)
					STDERR.puts "Source of error: #{callback.source_location}"
				else
					STDERR.puts "Error is probably due to invalid callback. No source location found."
				end
			end
		end
	end
end