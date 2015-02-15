
#In this file you will find patches to different objects and classes for conveniency classes.

# Public: Monkey patching the Class class to add the awesome attr_accessor style methods to other classes
#
# Examples
#
#   class Foo
#		receiving "I want this message type", "and this", lambda{|e| puts "and do this with them"}
#		receiving "Ohh!! And also this", lambda{|e| puts "but only do this"}
#		responding "This one I know!", lambda{|e| puts "the answer is #{e+1}"}
#		responding "This also", "and this", lambda{|e| puts "the answer is #{e+2}"}
#	end
#	foo = Foo.new
#
class Class
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
		puts "args: #{args.inspect}"
		puts "self: #{self.inspect}"
		puts "self.class_eval{self.inspect}: #{self.class_eval{self.inspect}}"
		puts "self.class_eval{self.method_defined?(args[-1])}: #{self.class_eval{self.method_defined?(args[-1])}}"

		raise "No callback provided" unless args[-1].respond_to?(:call) || self.class_eval{self.method_defined?(args[-1])}
		
		return {
			:types                   => args[0..-2],
			:callback                => args[-1],
			:callback_is_method_name => !args[-1].respond_to?(:call)
		}
	end
end


# class Object

# end