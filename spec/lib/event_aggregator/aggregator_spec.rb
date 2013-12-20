require 'spec_helper'

describe EventAggregator::Aggregator do
	let(:listener)       { (Class.new { include EventAggregator::Listener }).new }
	let(:listener_class) { Class.new { include EventAggregator::Listener }}
	let(:message_type)   { Faker::Name.name }
	let(:data)   		 { Faker::Name.name }
	let(:callback)		 { lambda{ |data| } }

	before(:each) do
		EventAggregator::Aggregator.class_variable_set :@@listener, Hash.new{|h, k| h[k] = []}
	end
	describe "self.register" do
		describe 'legal parameters' do
			it 'registered at correct place' do
				EventAggregator::Aggregator.register(listener, message_type, callback)
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type]).to include([listener, callback])
			end

			it 'should not be registered in wrong place' do
				EventAggregator::Aggregator.register(listener, message_type, callback)
				EventAggregator::Aggregator.class_variable_get(:@@listeners).each do |e|
					if e[0] == message_type
						expect(e[1]).to include([listener, callback])
					else
						expect(e[1]).to_not include([listener, callback])
					end
				end
			end
		end
		describe 'illegal parameters' do
			it 'should not allow nil as message type' do
				expect{EventAggregator::Aggregator.register(nil, message_type, callback)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
			end
			it 'should not allow non-listener to register' do
				expect{EventAggregator::Aggregator.register(EventAggregator::Message.new("a","b"), message_type, callback)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.register("string", message_type, callback)}.to_not                              change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.register(1, message_type, callback)}.to_not                                     change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.register(2.0, message_type, callback)}.to_not                                   change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
			end
		end
	end

	describe "self.unregister" do
		describe 'legal parameters'  do
			it 'should decrease count by 1' do
				EventAggregator::Aggregator.register(listener, message_type, callback)
				expect{EventAggregator::Aggregator.unregister(listener, message_type)}.to change{EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type].length}.by(-1)
			end
			it 'should be remove from list' do
				EventAggregator::Aggregator.register(listener, message_type, callback)
				EventAggregator::Aggregator.unregister(listener, message_type)
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type]).to_not include([listener, callback])
			end
			it 'should keep listener in unrelated lists' do
				message_type2 = message_type + " different"
				
				EventAggregator::Aggregator.register(listener, message_type, callback)
				EventAggregator::Aggregator.register(listener, message_type2, callback)
				
				EventAggregator::Aggregator.unregister(listener, message_type)
				
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type2]).to include([listener, callback])
			end
		end
		describe 'unregitering nonregisterd listener' do
			it 'should not change list' do
				message_type1 = message_type + " different 1"
				message_type2 = message_type + " different 2"
				message_type3 = message_type + " different 3"
				listener1 	  = listener_class.new
				listener2 	  = listener_class.new
				listener3 	  = listener_class.new

				EventAggregator::Aggregator.register(listener1, message_type1, callback)
				EventAggregator::Aggregator.register(listener2, message_type2, callback)
				EventAggregator::Aggregator.register(listener3, message_type3, callback)
				
				#Touching hash
				EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type]

				expect{EventAggregator::Aggregator.unregister(listener1, message_type)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.unregister(listener2, message_type)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.unregister(listener3, message_type)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}

				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type1]).to include([listener1, callback])
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type2]).to include([listener2, callback])
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type3]).to include([listener3, callback])
			end
		end
		describe 'unregitering listener from wrong message type' do
			it 'should not change list' do
				message_type2 = message_type + " different"

				EventAggregator::Aggregator.register(listener, message_type, callback)

				expect{EventAggregator::Aggregator.unregister(listener, message_type2)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type]}
			end
		end
		describe 'unregitering non-listener class' do
			it 'should not change register list' do
				#Touching hash
				EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type]

				expect{EventAggregator::Aggregator.unregister(EventAggregator::Message.new("a","b"), message_type)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.unregister("string", message_type)}.to_not                              change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.unregister(1, message_type)}.to_not                                     change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.unregister(2.0, message_type)}.to_not                                   change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
			end
		end
	end

	describe "self.unregister_all" do
		describe "unregistering listener registered to one message type" do
			it "should unregister from list" do
				EventAggregator::Aggregator.register(listener, message_type, callback)

				EventAggregator::Aggregator.unregister_all(listener)
				
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type]).to_not  include([listener, callback])
			end
			it "should not unregister wrong listener" do
				listener2 = listener_class.new
				listener3 = listener_class.new
				listener4 = listener_class.new

				message_type2 = message_type + " different"
				message_type3 = message_type + " different 2"

				EventAggregator::Aggregator.register(listener, message_type, callback)
				EventAggregator::Aggregator.register(listener2, message_type, callback)
				EventAggregator::Aggregator.register(listener3, message_type2, callback)
				EventAggregator::Aggregator.register(listener4, message_type3, callback)

				
				EventAggregator::Aggregator.unregister_all(listener)

				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type]).to include([listener2, callback])
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type2]).to include([listener3, callback])
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type3]).to include([listener4, callback])
			end
		end
		describe "unregistering listener registered for several message types" do
			it "should unregister from all lists" do
				EventAggregator::Aggregator.register(listener, message_type, callback)
				message_type2 = message_type + " different"
				EventAggregator::Aggregator.register(listener, message_type2, callback)

				EventAggregator::Aggregator.unregister_all(listener)

				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type]).to_not include([listener, callback])
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type2]).to_not include([listener, callback])
			end
		end
	end

	describe "self.message_publish" do
		describe 'legal parameters' do
			it 'should receive correct messages' do
				EventAggregator::Aggregator.register(listener, message_type, callback)
				message = EventAggregator::Message.new(message_type, data)

				expect(callback).to receive(:call).with(data)

				EventAggregator::Aggregator.message_publish(message)
			end
			it 'should not receive incorrect messages' do
				message_type2 = message_type + " different"
				
				EventAggregator::Aggregator.register(listener, message_type, callback)
				message = EventAggregator::Message.new(message_type2, data)

				expect(callback).to_not receive(:call).with(data)

				EventAggregator::Aggregator.message_publish(message)
			end

			it 'should send message to right listener' do
				listener2 = listener_class.new
				message_type2 = message_type + " different"

				callback2 = lambda{|data|}

				EventAggregator::Aggregator.register(listener, message_type, callback)
				EventAggregator::Aggregator.register(listener, message_type2, callback2)

				message = EventAggregator::Message.new(message_type, data)

				expect(callback).to receive(:call).with(data)
				expect(callback2).to_not receive(:call)

				EventAggregator::Aggregator.message_publish(message)
			end
		end
		describe 'illegal parameters' do
			it 'non-message type' do
				expect{EventAggregator::Aggregator.message_publish("string")}.to raise_error
				expect{EventAggregator::Aggregator.message_publish(1)}.to        raise_error
				expect{EventAggregator::Aggregator.message_publish(listener)}.to raise_error
				expect{EventAggregator::Aggregator.message_publish()}.to         raise_error
				expect{EventAggregator::Aggregator.message_publish(nil)}.to      raise_error
			end
		end
	end
end
