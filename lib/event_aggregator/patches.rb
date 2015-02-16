module EventAggregator

	#In this file you will find patches to different objects and classes for conveniency classes.

	# Public: Monkey patching the Class class to add the awesome attr_accessor style methods to other classes
	#
	# Examples
	#
	#   class Foo
	#       using EventAggregator
	#		receiving "I want this event type", "and this", lambda{|e| puts "and do this with them"}
	#		receiving "Ohh!! And also this", lambda{|e| puts "but only do this"}
	#		responding "This one I know!", lambda{|e| puts "the answer is #{e+1}"}
	#		responding "This also", "and this", lambda{|e| puts "the answer is #{e+2}"}
	#	end
	#	foo = Foo.new
	#
	refine Class do
		def receiving(*args)
			type_callback = verify_event_aggregator_args(args)

			self.class_eval do
				original_method = instance_method(:initialize)
				define_method(:initialize) do |*args, &block|
					original_method.bind(self).call(*args, &block)
					
					type_callback[:types].each do |type|
						EA::Aggregator.register( self, type, type_callback[:callback])
					end
				end
			end
		end

		def receive_all(*args)
			type_callback = verify_event_aggregator_args(args)

			self.class_eval do
				original_method = instance_method(:initialize)

				define_method(:initialize) do |*args, &block|
					original_method.bind(self).call(*args, &block)
					EA::Aggregator.register_all(self, type_callback[:callback])
				end
			end
		end

		def responding(*args)
			type_callback = verify_event_aggregator_args(args)

			self.class_eval do
				original_method = instance_method(:initialize)
				define_method(:initialize) do |*args, &block|
					original_method.bind(self).call(*args, &block)
					
					type_callback[:types].each do |type|
						EA::Aggregator.register_producer(self, type, type_callback[:callback])
					end
				end
			end
		end

		private
		def verify_event_aggregator_args(args)
			raise "No callback provided" unless args[-1].respond_to?(:call) || args[-1].is_a?(String) || args[-1].is_a?(Symbol)
			
			return {
				:types                   => args[0..-2],
				:callback                => args[-1]
			}
		end
	end

	#TODO: Consider if this is a sin or not. It can interfere with other stuff. Maybe rename to something like event_aggregator_publish
	refine Object do
		include EventAggregator::Listener
	end

end