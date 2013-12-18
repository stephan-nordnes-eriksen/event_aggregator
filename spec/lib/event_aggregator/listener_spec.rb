require 'spec_helper'

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
	describe '.receive_message' do
		describe 'legal parameters' do
			it 'execute callback' do
				#TODO: This fails because the method is private. This is subject to
				# refactor because the method is stroed in the module by a hack. 
				# This stuff should be moved to the aggregator, or somewhere else.
				listener.message_type_to_receive_add(message_type, lambda_method)

				expect(lambda_method).to receive(:call)

				@message.publish
			end
		end
		describe 'illegal parameters' do
			it 'pending' do
				pending "not implemented"
			end
		end
	end
	
	describe '.message_type_to_receive_add' do
		describe 'legal parameters' do
			it 'pending' do
				pending "not implemented"
			end
		end
		describe 'illegal parameters' do
			it 'not valid' do
				expect{listener.message_publish(message_type, nil)}.to                raise_error
				expect{listener.message_publish(message_type, 1)}.to                  raise_error
				expect{listener.message_publish(message_type, "string")}.to           raise_error
				expect{listener.message_publish(message_type, listener_class.new)}.to raise_error
			end
		end
	end

	describe '.message_type_to_receive_remove' do
		describe 'legal parameters' do
			it 'pending' do
				pending "not implemented"
			end
			it 'not recieve callbacks' do
				listener.message_type_to_receive_add(message_type, lambda_method)
				listener.message_type_to_receive_remove(message_type)

				expect(lambda_method).to_not receive(:call)

				#TODO: Maybe test at a lower level? test the actual event_listener_listens_to object?
				@message.publish
			end
		end
		describe 'illegal parameters' do
			it 'pending' do
				pending "not implemented"
			end
		end
	end
end
