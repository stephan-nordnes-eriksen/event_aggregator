require 'spec_helper'

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

				listener.send(:event_type_register, event_type, callback)
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
				listener.send(:event_type_register, event_type, callback)

				expect(EventAggregator::Aggregator).to receive(:unregister).with(listener, event_type)

				listener.send(:event_type_unregister, event_type)
			end
		end
	end

	describe '.event_type_register_all' do
		describe 'legal parameters' do
			it 'invoke aggregator unregister_all' do
				expect(EventAggregator::Aggregator).to receive(:register_all).with(listener,callback)

				listener.send(:event_type_register_all, callback)
			end
		end
	end

	describe '.event_type_unregister_all' do
		describe 'legal parameters' do
			it 'invoke aggregator unregister' do
				expect(EventAggregator::Aggregator).to receive(:unregister_all).with(listener)
				listener.send(:event_type_unregister_all)
			end
		end
	end

	describe ".event_type_producer_register" do
		describe 'legal parameters' do
			it "invoke aggregator register_producer" do
				expect(EventAggregator::Aggregator).to receive(:register_producer).with(listener, event_type, callback)
				listener.send(:producer_register, event_type, callback)
			end
		end
	end

	describe "event_publish(type, data, async = true, consisten_data = true)" do
		it "creates and publishes new Event" do
			a = Object.new

			message_spy = spy("message spy")
			expect(EA::E).to receive(:new).with("type", "data", true, true).and_return(message_spy)
			expect(message_spy).to receive(:publish)
			a.send(:event_publish, "type", "data")
		end
	end

	describe "event_request(type, data)" do
		it "creates and request new Event" do
			a = Object.new

			message_spy = spy("message spy")
			expect(EA::E).to receive(:new).with("type", "data").and_return(message_spy)
			expect(message_spy).to receive(:request)
			a.send(:event_request, "type", "data")
		end
	end
end
