require 'spec_helper'

describe EventAggregator::Event do
	let(:event_type)   { Faker::Name.name }
	let(:data)           { Faker::Name.name }
	let(:listener_class) { (Class.new { include EventAggregator::Listener }) }
	let(:callback)		 { lambda{ |data| } }

	before(:each) do
		EventAggregator::Aggregator.reset
	end
	describe '.initialize' do
		describe 'legal parameters' do
			it 'allows nil data' do
				expect{EventAggregator::Event.new(event_type, nil)}.to_not raise_error
			end
			it 'initialize data publicly available' do
				event = EventAggregator::Event.new(event_type, data)

				expect(event.event_type).to equal(event_type)
				expect(event.data).to         equal(data)
			end
		end
		describe 'illegal parameters' do
			it 'require initialize data' do
				expect{EventAggregator::Event.new(event_type)}      .to     raise_error
				expect{EventAggregator::Event.new(data)}              .to     raise_error
				expect{EventAggregator::Event.new(event_type, data)}.to_not raise_error
			end
			it 'non-nil event_type' do
				expect{EventAggregator::Event.new(nil, data)}.to raise_error
			end
		end
	end

	describe '.publish' do
		before(:each) do
			@listener_one = listener_class.new
			@listener_two = listener_class.new

			EventAggregator::Aggregator.register(@listener_one, event_type, callback)
			EventAggregator::Aggregator.register(@listener_two, event_type+" different", callback)
		end

		it 'invoke event_publish on aggregator' do
			event = EventAggregator::Event.new(event_type, data)

			expect(EventAggregator::Aggregator).to receive(:event_publish).with(event)

			event.publish
		end
	end

	describe ".request" do
		it 'invoke event_request on aggregator' do
			event = EventAggregator::Event.new(event_type, data)

			expect(EventAggregator::Aggregator).to receive(:event_request).with(event)

			event.request
		end
	end
end
