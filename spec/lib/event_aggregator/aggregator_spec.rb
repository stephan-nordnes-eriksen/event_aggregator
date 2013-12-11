require 'spec_helper'

describe EventAggregator::Aggregator do
	describe "self.register" do
		describe 'when registering legal listener' do
			let(:listener_class) { Class.new { include EventAggregator::Listener }} 
			let(:listener) { (Class.new { include EventAggregator::Listener }).new } 
			let(:listener_mock) {  }

			before(:each) do
				EventAggregator::Aggregator.class_variable_set :@@listener, Hash.new{|h, k| h[k] = []}
			end
			it 'increases register count' do
				expect{EventAggregator::Aggregator.register(listener, Faker::Name.name)}.to change{EventAggregator::Aggregator.class_variable_get(:@@listeners).length}.by(1)
			end

			it 'registered at correct place' do
				name = Faker::Name.name
				EventAggregator::Aggregator.register(listener, name)
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[name]).to include(listener)
			end

			it 'should not be registered in wrong place' do
				name = Faker::Name.name
				EventAggregator::Aggregator.register(listener, name)
				EventAggregator::Aggregator.class_variable_get(:@@listeners).each do |e|
					if e[0] == name
						expect(e[1]).to include(listener)
					else
						expect(e[1]).to_not include(listener)
					end
				end
			end
		end
		describe 'when illegal parameters' do
			it 'should not allow nil as message type' do
				expect{EventAggregator::Aggregator.register(nil, Faker::Name.name)}.to change{EventAggregator::Aggregator.class_variable_get(:@@listeners).length}.by(0)
			end
			it 'should not allow non-listener to register' do
				expect{EventAggregator::Aggregator.register(EventAggregator::Message.new("a","b"), Faker::Name.name)}.to change{EventAggregator::Aggregator.class_variable_get(:@@listeners).length}.by(0)
				expect{EventAggregator::Aggregator.register("string", Faker::Name.name)}.to change{EventAggregator::Aggregator.class_variable_get(:@@listeners).length}.by(0)
				expect{EventAggregator::Aggregator.register(1, Faker::Name.name)}.to change{EventAggregator::Aggregator.class_variable_get(:@@listeners).length}.by(0)
				expect{EventAggregator::Aggregator.register(2.0, Faker::Name.name)}.to change{EventAggregator::Aggregator.class_variable_get(:@@listeners).length}.by(0)
			end
		end
	end

	describe "self.unregister" do
		let(:listener) { (Class.new { include EventAggregator::Listener }).new } 
		before(:each) do
			EventAggregator::Aggregator.class_variable_set :@@listener, Hash.new{|h, k| h[k] = []}
		end
		describe 'when unregitering registered listener from correct message type'  do
			it 'should decrease count by 1' do
				name = Faker::Name.name
				EventAggregator::Aggregator.register(listener, name)
				expect{EventAggregator::Aggregator.unregister(listener, name)}.to change{EventAggregator::Aggregator.class_variable_get(:@@listeners)[name].length}.by(-1)
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

	describe "self.unregister_all" do

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
