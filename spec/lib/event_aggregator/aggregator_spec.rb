require 'spec_helper'

describe EventAggregator::Aggregator do
	let(:listener)       { (Class.new { include EventAggregator::Listener }).new }
	let(:listener_class) { Class.new { include EventAggregator::Listener }}
	let(:message_type)   { Faker::Name.name }
	describe "self.register" do
		describe 'when registering legal listener' do
			
			before(:each) do
				EventAggregator::Aggregator.class_variable_set :@@listener, Hash.new{|h, k| h[k] = []}
			end

			it 'registered at correct place' do
				EventAggregator::Aggregator.register(listener, message_type)
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type]).to include(listener)
			end

			it 'should not be registered in wrong place' do
				EventAggregator::Aggregator.register(listener, message_type)
				EventAggregator::Aggregator.class_variable_get(:@@listeners).each do |e|
					if e[0] == message_type
						expect(e[1]).to include(listener)
					else
						expect(e[1]).to_not include(listener)
					end
				end
			end
		end
		describe 'when illegal parameters' do
			it 'should not allow nil as message type' do
				expect{EventAggregator::Aggregator.register(nil, message_type)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
			end
			it 'should not allow non-listener to register' do
				expect{EventAggregator::Aggregator.register(EventAggregator::Message.new("a","b"), message_type)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.register("string", message_type)}.to_not                              change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.register(1, message_type)}.to_not                                     change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.register(2.0, message_type)}.to_not                                   change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
			end
		end
	end

	describe "self.unregister" do
		before(:each) do
			EventAggregator::Aggregator.class_variable_set :@@listener, Hash.new{|h, k| h[k] = []}
		end
		describe 'when unregitering registered listener from correct message type'  do
			it 'should decrease count by 1' do
				EventAggregator::Aggregator.register(listener, message_type)
				expect{EventAggregator::Aggregator.unregister(listener, message_type)}.to change{EventAggregator::Aggregator.class_variable_get(:@@listeners)[name].length}.by(-1)
			end
		end
		describe 'when unregitering nonregisterd listener' do
			it 'should not change list' do
				message_type1 = message_type + " different"
				message_type2 = message_type + " different 2"
				message_type3 = message_type + " different 3"
				listener1 = EventAggregator::Aggregator.register(listener_class.new, message_type1)
				listener2 = EventAggregator::Aggregator.register(listener_class.new, message_type2)
				listener3 = EventAggregator::Aggregator.register(listener_class.new, message_type3)

				expect{EventAggregator::Aggregator.unregister(listener1, message_type)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.unregister(listener2, message_type)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.unregister(listener3, message_type)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}

				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type1]).to include(listener1)
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type2]).to include(listener2)
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type3]).to include(listener3)
			end
		end
		describe 'when unregitering listener from wrong message type' do
			it 'should not change list' do
				message_type2 = message_type << " different"

				EventAggregator::Aggregator.register(listener, message_type)
				expect{EventAggregator::Aggregator.unregister(listener, message_type2)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
			end
		end
		describe 'when unregitering non-listener class' do
			it 'should not change register list' do
				expect{EventAggregator::Aggregator.unregister(EventAggregator::Message.new("a","b"), message_type)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.unregister("string", message_type)}.to_not                              change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.unregister(1, message_type)}.to_not                                     change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.unregister(2.0, message_type)}.to_not                                   change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
			end
		end
	end

	describe "self.unregister_all" do
		before(:each) do
			EventAggregator::Aggregator.class_variable_set :@@listener, Hash.new{|h, k| h[k] = []}
		end
		describe "when unregistering listener registered to one message type" do
			it "should unregister from list" do
				EventAggregator::Aggregator.register(listener, message_type)
				expect{EventAggregator::Aggregator.unregister(listener, message_type)}.to change{EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type]}.by(-1)
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type]).not_to include(listener)
				pending "needs more cases"
			end
		end
		describe "when unregistering listener registered for several message types" do
			it "should unregister from all lists" do
				pending "not implemented"
			end
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
