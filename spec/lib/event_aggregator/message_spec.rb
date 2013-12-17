require 'spec_helper'

describe EventAggregator::Message do
    describe '.publish' do
		let(:message_type) {Faker::Name.name}
		let(:data)         {Faker::Name.name}
		let(:listener_class) { (Class.new { include EventAggregator::Listener }) }

    	before(:each) do
			EventAggregator::Aggregator.class_variable_set :@@listener, Hash.new{|h, k| h[k] = []}
			@listener_one = listener_class.new
			@listener_two = listener_class.new
			
			EventAggregator::Aggregator.register(@listener_one, message_type)
			EventAggregator::Aggregator.register(@listener_two, message_type+" different")
		end

    	it 'should be recieved by a correct subscribers' do
    		message = EventAggregator::Message.new(message_type, data)
    		expect(@listener_one).to receive(:recieve_message).with(message)
    		expect(@listener_two).to_not receive(:recieve_message)

    		message.publish
    	end
    	it 'should be published to the aggregator' do
    		message = EventAggregator::Message.new(message_type, data)
    		expect{EventAggregator::Aggregator}.to recieve(:message_publish).with(message)

    		message.publish
    	end
	end

	describe 'self.new' do
		let(:message_type) {Faker::Name.name}
		let(:data)         {Faker::Name.name}
			
		it 'should require initialize data' do
			expect{EventAggregator::Message.new(message_type)}.to raise_error
			expect{EventAggregator::Message.new(data)}.to raise_error
			expect{EventAggregator::Message.new(message_type, data)}.to_not raise_error
		end
		it 'should have non-nil message_type' do
			#expect{EventAggregator::Message.new(nil, data)}.to raise_error
		end
		it 'should have initialize data publicly available' do
			message = EventAggregator::Message.new(message_type, data)
			
			expect(message.message_type).to equal(message_type)
			expect(message.data).to equal(data)
		end
	end
end
