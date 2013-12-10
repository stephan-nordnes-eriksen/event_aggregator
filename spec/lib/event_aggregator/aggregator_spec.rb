require 'spec_helper'



class DummyListener
	include EventAggregator::Listener
end


describe EventAggregator::Aggregator do
	describe "self.register" do
		describe 'when registering legal listener' do
			before(:each) do
				@listener = DummyListener.new
			end
			it 'increases register count' do
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners).length).to equal(0)
				EventAggregator::Aggregator.register(@listener, Faker::Name.name)
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners).length).to equal(1)
			end
		end
		describe 'when illegal parameters' do
			it 'should not allow nil as message type' do
				pending "not implemented"
			end
			it 'should not allow non-listener to register' do
				pending "not implemented"
			end
		end
	end

	describe "self.unregister" do
		describe 'when unregitering registered listener from correct message type'  do
			before(:each) do
				@listener = DummyListener.new
			end
		end
		describe 'when unregitering nonregisterd listener' do
			pending "not implemented"
		end
		describe 'when unregitering listener from wrong message type' do
			pending "not implemented"
		end
		describe 'when unregitering non-listener class' do
			pending "not implemented"
		end
	end

	describe "self.message_publish" do
		describe 'when recieving correct messages' do
			it 'should recieve correct messages' do
				pending "not implemented"
			end
			it 'should recieve incorrect messages' do
				pending "not implemented"
			end
		end
		describe 'when recieving illegal parameters' do
			it 'non-message type' do
				pending "not implemented"
			end
		end
	end
end
