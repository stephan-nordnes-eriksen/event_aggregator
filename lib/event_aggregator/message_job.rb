module EventAggregator
	class MessageJob
		include SuckerPunch::Job

		def perform(data, callback)
			callback.call(data)
		end
	end
end