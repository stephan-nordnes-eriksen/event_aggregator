require 'spec_helper'


# Public: Some ruby trickery to be able to test private methods
#
class Class
  def publicize_methods
    saved_private_instance_methods = self.private_instance_methods
    self.class_eval { public *saved_private_instance_methods }
    yield
    self.class_eval { private *saved_private_instance_methods }
  end
end

describe EventAggregator::Listener do
	let(:listener)       { (Class.new { include EventAggregator::Listener }).new }
	let(:listener_class) { Class.new { include EventAggregator::Listener } }
	let(:message_type)   { Faker::Name.name }
	let(:lambda_method)  { lambda { |data| }}
	let(:data)  		 { Faker::Name.name }

	before(:each) do
		EventAggregator::Aggregator.class_variable_set :@@listener, Hash.new{|h, k| h[k] = []}
		@message = EventAggregator::Message.new(message_type, data)
	end

	describe '.message_type_to_receive_add' do
		describe 'legal parameters' do
			it 'should register at aggregator' do
				expect(EventAggregator::Aggregator).to receive(:register).with(listener, message_type, lambda_method)
				
				listener.class.publicize_methods do
					listener.message_type_register(message_type, lambda_method)
				end
			end
			it 'pending' do
				pending "not implemented"
			end
		end
		describe 'illegal parameters' do
			it 'not valid' do
				expect{listener.message_type_register(message_type, nil)}.to                raise_error
				expect{listener.message_type_register(message_type, 1)}.to                  raise_error
				expect{listener.message_type_register(message_type, "string")}.to           raise_error
				expect{listener.message_type_register(message_type, listener_class.new)}.to raise_error
			end
		end
	end

	describe '.message_type_to_receive_remove' do
		describe 'legal parameters' do
			it 'invoke aggregator unregister' do
				listener.class.publicize_methods do
					listener.message_type_register(message_type, lambda_method)
					
					expect(EventAggregator::Aggregator).to receive(:unregister).with(listener, message_type)

					listener.message_type_unregister(message_type)
				end
			end
		end
		describe 'illegal parameters' do
			it 'not registered reciever' do
				pending "This will really likely be removed in next refactor"
			end
		end
	end
end
