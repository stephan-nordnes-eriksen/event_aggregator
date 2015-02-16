require 'spec_helper'


# Public: Some ruby trickery to be able to test private methods
#
# Example:
# whatever_object.class.publicize_methods do
# #... execute private methods
# end
class Class
	def publicize_methods
		saved_private_instance_methods = self.private_instance_methods
		self.class_eval { public *saved_private_instance_methods }
		yield
		self.class_eval { private *saved_private_instance_methods }
	end
end

describe EventAggregator::Listener do
	let(:listener)           { (Class.new { include EventAggregator::Listener }).new }
	let(:listener_class)     { Class.new { include EventAggregator::Listener } }
	let(:event_type)       { Faker::Name.name }
	let(:callback)      { lambda { |data| } }
	let(:data)  		     { Faker::Name.name }
	let(:recieve_all_method) { lambda { |event| } }

	before(:each) do
		EventAggregator::Aggregator.reset
		@event = EventAggregator::Event.new(event_type, data)
	end

	describe '.event_type_register' do
		describe 'legal parameters' do
			it 'invoke aggregator register' do
				expect(EventAggregator::Aggregator).to receive(:register).with(listener, event_type, callback)

				listener.class.publicize_methods do
					listener.event_type_register(event_type, callback)
				end
			end
		end
		describe 'illegal parameters' do
			it 'raise error' do
				expect{listener.event_type_register(event_type, nil)}.to                raise_error
				expect{listener.event_type_register(event_type, 1)}.to                  raise_error
				expect{listener.event_type_register(event_type, "string")}.to           raise_error
				expect{listener.event_type_register(event_type, listener_class.new)}.to raise_error
			end
		end
	end

	describe '.event_type_unregister' do
		describe 'legal parameters' do
			it 'invoke aggregator unregister' do
				listener.class.publicize_methods do
					listener.event_type_register(event_type, callback)

					expect(EventAggregator::Aggregator).to receive(:unregister).with(listener, event_type)

					listener.event_type_unregister(event_type)
				end
			end
		end
	end

	describe '.event_type_register_all' do
		describe 'legal parameters' do
			it 'invoke aggregator unregister_all' do
				listener.class.publicize_methods do
					expect(EventAggregator::Aggregator).to receive(:register_all).with(listener,callback)

					listener.event_type_register_all(callback)
				end
			end
		end
	end

	describe '.event_type_unregister_all' do
		describe 'legal parameters' do
			it 'invoke aggregator unregister' do
				listener.class.publicize_methods do
					expect(EventAggregator::Aggregator).to receive(:unregister_all).with(listener)

					listener.event_type_unregister_all()
				end
			end
		end
	end

	describe ".event_type_producer_register" do
		describe 'legal parameters' do
			it "invoke aggregator register_producer" do
				expect(EventAggregator::Aggregator).to receive(:register_producer).with(listener, event_type, callback)
				listener.class.publicize_methods do
					listener.producer_register(event_type, callback)
				end
			end
		end
	end
end
