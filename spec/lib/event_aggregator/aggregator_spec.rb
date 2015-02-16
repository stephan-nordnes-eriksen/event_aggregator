require 'spec_helper'

describe EventAggregator::Aggregator do
	let(:listener)       { (Class.new { include EventAggregator::Listener }).new }
	let(:producer)       { (Class.new { include EventAggregator::Listener }).new }
	let(:listener_class) { Class.new { include EventAggregator::Listener }}
	let(:event_type)   { Faker::Name.name }
	let(:data)           { Faker::Name.name }
	let(:callback)       { lambda{ |data| } }
	let(:random_string)  { Faker::Internet.password }
	let(:random_number)  { Faker::Number.number(rand(9)) }
	let(:empty_object)   { Object.new }

	before(:all) do
		EventAggregator::Aggregator.reset
	end

	after(:each) do
		EventAggregator::Aggregator.restart_pool
	end
	describe "self.register" do
		describe 'legal parameters' do
			it "accepts different callback types" do
				expect{EventAggregator::Aggregator.register(listener, event_type, lambda { |args| })}.to_not raise_error
				expect{EventAggregator::Aggregator.register(listener, event_type, Proc.new{ |args| })}.to_not raise_error

				listener2 = (Class.new { include EventAggregator::Listener; def testmethod(data); end;}).new

				expect{EventAggregator::Aggregator.register(listener2, event_type, :testmethod)}.to_not raise_error
				expect{EventAggregator::Aggregator.register(listener2, event_type, "testmethod")}.to_not raise_error
			end

			it "no errors" do
				expect{EventAggregator::Aggregator.register(listener, event_type, callback)}.to_not raise_error
			end
			it "is stored" do
				expect{EventAggregator::Aggregator.register(listener, event_type, callback)}.to change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
			end
			it "overwrite previous callback" do
				callback2 = lambda { |data| }
				EventAggregator::Aggregator.register(listener, event_type, callback)
				EventAggregator::Aggregator.register(listener, event_type, callback2)
				
				expect(callback).to_not receive(:call)
				expect(callback2).to receive(:call)

				EventAggregator::Aggregator.event_publish(EventAggregator::Event.new(event_type, data))
			end
		end
		describe 'illegal parameters' do
			it 'event_type raise error' do
				expect{EventAggregator::Aggregator.register(listener, nil, callback)}.to raise_error
			end
			it "listener raise error" do
				expect{EventAggregator::Aggregator.register(nil                                  , event_type, callback)}.to raise_error
				#expect{EventAggregator::Aggregator.register(EventAggregator::Event.new("a","b"), event_type, callback)}.to raise_error #Should no longer raise error
				#expect{EventAggregator::Aggregator.register(random_string                        , event_type, callback)}.to raise_error #Should no longer raise error
				#expect{EventAggregator::Aggregator.register(random_number                        , event_type, callback)}.to raise_error #Should no longer raise error
				#expect{EventAggregator::Aggregator.register(2.0                                  , event_type, callback)}.to raise_error #Should no longer raise error
			end
			it 'callback raise error' do
				expect{EventAggregator::Aggregator.register(listener, event_type, nil                                  )}.to raise_error
				expect{EventAggregator::Aggregator.register(listener, event_type, EventAggregator::Event.new("a","b"))}.to raise_error
				expect{EventAggregator::Aggregator.register(listener, event_type, random_string                        )}.to raise_error
				expect{EventAggregator::Aggregator.register(listener, event_type, random_number                        )}.to raise_error
				expect{EventAggregator::Aggregator.register(listener, event_type, 2.0                                  )}.to raise_error
			end
		end
	end

	describe "self.unregister" do
		describe 'legal parameters'  do
			it 'decrease count by 1' do
				EventAggregator::Aggregator.register(listener, event_type, callback)
				expect{EventAggregator::Aggregator.unregister(listener, event_type)}.to change{EventAggregator::Aggregator.class_variable_get(:@@listeners)[event_type].length}.by(-1)
			end
			it 'be remove from list' do
				EventAggregator::Aggregator.register(listener, event_type, callback)
				EventAggregator::Aggregator.unregister(listener, event_type)
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[event_type]).to_not include([listener, callback])
			end
			it 'keep listener in unrelated lists' do
				event_type2 = event_type + " different"

				EventAggregator::Aggregator.register(listener, event_type, callback)
				EventAggregator::Aggregator.register(listener, event_type2, callback)

				EventAggregator::Aggregator.unregister(listener, event_type)

				expect(callback).to receive(:call).once

				EventAggregator::Aggregator.event_publish(EventAggregator::Event.new(event_type2,data))
			end
		end
		describe 'unregitering nonregisterd listener' do
			it 'not change list' do
				event_type1 = event_type + " different 1"
				event_type2 = event_type + " different 2"
				event_type3 = event_type + " different 3"
				listener1 	  = listener_class.new
				listener2 	  = listener_class.new
				listener3 	  = listener_class.new

				EventAggregator::Aggregator.register(listener1, event_type1, callback)
				EventAggregator::Aggregator.register(listener2, event_type2, callback)
				EventAggregator::Aggregator.register(listener3, event_type3, callback)

				#Touching hash
				EventAggregator::Aggregator.class_variable_get(:@@listeners)[event_type]

				expect{EventAggregator::Aggregator.unregister(listener1, event_type)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.unregister(listener2, event_type)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.unregister(listener3, event_type)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				
				expect(callback).to receive(:call).exactly(3).times

				EventAggregator::Aggregator.event_publish(EventAggregator::Event.new(event_type1,data))
				EventAggregator::Aggregator.event_publish(EventAggregator::Event.new(event_type2,data))
				EventAggregator::Aggregator.event_publish(EventAggregator::Event.new(event_type3,data))
			end
		end
		describe 'unregitering listener from wrong event type' do
			it 'not change list' do
				event_type2 = event_type + " different"

				EventAggregator::Aggregator.register(listener, event_type, callback)

				expect{EventAggregator::Aggregator.unregister(listener, event_type2)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)[event_type]}
			end
		end
		describe 'unregitering non-listener class' do
			it 'not change register list' do
				#Touching hash
				EventAggregator::Aggregator.class_variable_get(:@@listeners)[event_type]

				expect{EventAggregator::Aggregator.unregister(EventAggregator::Event.new("a","b"), event_type)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.unregister("string", event_type)}.to_not                              change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.unregister(1, event_type)}.to_not                                     change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.unregister(2.0, event_type)}.to_not                                   change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
			end
		end
	end

	describe "self.unregister_all" do
		describe "unregistering listener registered to one event type" do
			it "unregister from list" do
				EventAggregator::Aggregator.register(listener, event_type, callback)

				EventAggregator::Aggregator.unregister_all(listener)

				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[event_type]).to_not  include([listener, callback])
			end
			it "not unregister wrong listener" do
				listener2 = listener_class.new
				listener3 = listener_class.new
				listener4 = listener_class.new

				event_type2 = event_type + " different"
				event_type3 = event_type + " different 2"

				EventAggregator::Aggregator.register(listener, event_type, callback)
				EventAggregator::Aggregator.register(listener2, event_type, callback)
				EventAggregator::Aggregator.register(listener3, event_type2, callback)
				EventAggregator::Aggregator.register(listener4, event_type3, callback)


				EventAggregator::Aggregator.unregister_all(listener)

				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[event_type][listener2]).to eq(callback)
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[event_type2][listener3]).to eq(callback)
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[event_type3][listener4]).to eq(callback)
			end
		end
		describe "unregistering listener registered for several event types" do
			it "unregister from all lists" do
				EventAggregator::Aggregator.register(listener, event_type, callback)
				event_type2 = event_type + " different"
				EventAggregator::Aggregator.register(listener, event_type2, callback)

				EventAggregator::Aggregator.unregister_all(listener)

				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[event_type]).to_not include([listener, callback])
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[event_type2]).to_not include([listener, callback])
			end
		end
		describe "unregistering listener registered for all" do
			it "unregister from all" do
				EventAggregator::Aggregator.register_all(listener, callback)

				EventAggregator::Aggregator.unregister_all(listener)

				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners_all)).to_not include([listener, callback])
			end
		end
	end

	describe "self.event_publish" do
		describe 'legal parameters' do
			it 'run correct callback' do
				EventAggregator::Aggregator.register(listener, event_type, callback)
				event = EventAggregator::Event.new(event_type, data)

				expect(callback).to receive(:call).with(data)

				EventAggregator::Aggregator.event_publish(event)
			end
			it 'not run incorrect callback' do
				event_type2 = event_type + " different"

				EventAggregator::Aggregator.register(listener, event_type, callback)
				event = EventAggregator::Event.new(event_type2, data)

				expect(callback).to_not receive(:call).with(data)

				EventAggregator::Aggregator.event_publish(event)
			end

			it 'run correct callback in list' do
				listener2 = listener_class.new
				event_type2 = event_type + " different"

				callback2 = lambda{|data|}

				EventAggregator::Aggregator.register(listener, event_type, callback)
				EventAggregator::Aggregator.register(listener, event_type2, callback2)

				event = EventAggregator::Event.new(event_type, data)

				expect(callback).to receive(:call).with(data)
				expect(callback2).to_not receive(:call)

				EventAggregator::Aggregator.event_publish(event)
			end
			it 'run all callbacks from register_all' do
				listener2 = listener_class.new
				callback2 = lambda{ |event| }
				EventAggregator::Aggregator.register_all(listener, callback)
				EventAggregator::Aggregator.register_all(listener2, callback2)

				event = EventAggregator::Event.new(event_type, data, true, true)

				expect(callback).to receive(:call).with(event)
				expect(callback2).to receive(:call).with(event)

				EventAggregator::Aggregator.event_publish(event)
			end

			it 'runs all callbacks when data is different types' do
				EventAggregator::Aggregator.register_all(listener, callback)
				
				event1 = EventAggregator::Event.new(event_type      , nil)
				event2 = EventAggregator::Event.new(event_type + "2", random_number)
				event3 = EventAggregator::Event.new(event_type + "3", random_string)
				event4 = EventAggregator::Event.new(event_type + "4", empty_object)
				event5 = EventAggregator::Event.new(event_type + "5", true)
				event6 = EventAggregator::Event.new(event_type + "6", false)

				expect(callback).to receive(:call).with(event1)
				expect(callback).to receive(:call).with(event2)
				expect(callback).to receive(:call).with(event3)
				expect(callback).to receive(:call).with(event4)
				expect(callback).to receive(:call).with(event5)
				expect(callback).to receive(:call).with(event6)

				EventAggregator::Aggregator.event_publish(event1)
				EventAggregator::Aggregator.event_publish(event2)
				EventAggregator::Aggregator.event_publish(event3)
				EventAggregator::Aggregator.event_publish(event4)
				EventAggregator::Aggregator.event_publish(event5)
				EventAggregator::Aggregator.event_publish(event6)
			end

			it 'runs all callbacks when data is different types register one' do
				EventAggregator::Aggregator.register(listener, event_type, callback)
				
				event1 = EventAggregator::Event.new(event_type, nil)
				event2 = EventAggregator::Event.new(event_type, random_number)
				event3 = EventAggregator::Event.new(event_type, random_string)
				event4 = EventAggregator::Event.new(event_type, empty_object)
				event5 = EventAggregator::Event.new(event_type, true)
				event6 = EventAggregator::Event.new(event_type, false)
				
				expect(callback).to receive(:call).with(nil)
				expect(callback).to receive(:call).with(random_number)
				expect(callback).to receive(:call).with(random_string)
				expect(callback).to receive(:call).with(empty_object)
				expect(callback).to receive(:call).with(true)
				expect(callback).to receive(:call).with(false)

				EventAggregator::Aggregator.event_publish(event1)
				EventAggregator::Aggregator.event_publish(event2)
				EventAggregator::Aggregator.event_publish(event3)
				EventAggregator::Aggregator.event_publish(event4)
				EventAggregator::Aggregator.event_publish(event5)
				EventAggregator::Aggregator.event_publish(event6)
			end

			it 'run all callbacks for all event types register all' do #Fails with seed: 34154
				EventAggregator::Aggregator.register_all(listener, callback)

				event1 = EventAggregator::Event.new(event_type      , data)
				event2 = EventAggregator::Event.new(event_type + "2", data)
				event3 = EventAggregator::Event.new(event_type + "3", data)
				event4 = EventAggregator::Event.new(event_type + "4", data)
				event5 = EventAggregator::Event.new(event_type + "5", data)
				event6 = EventAggregator::Event.new(event_type + "6", data)


				expect(callback).to receive(:call).with(event1)
				expect(callback).to receive(:call).with(event2)
				expect(callback).to receive(:call).with(event3)
				expect(callback).to receive(:call).with(event4)
				expect(callback).to receive(:call).with(event5)
				expect(callback).to receive(:call).with(event6)


				EventAggregator::Aggregator.event_publish(event1)
				EventAggregator::Aggregator.event_publish(event2)
				EventAggregator::Aggregator.event_publish(event3)
				EventAggregator::Aggregator.event_publish(event4)
				EventAggregator::Aggregator.event_publish(event5)
				EventAggregator::Aggregator.event_publish(event6)
			end

			it 'run correctly on all types of callback. async=true/false consisten_data=true/false' do
				EventAggregator::Aggregator.register_all(listener, callback)

				event1 = EventAggregator::Event.new(event_type      , data, true, true)
				event2 = EventAggregator::Event.new(event_type + "2", data, true, false)
				event3 = EventAggregator::Event.new(event_type + "3", data, false, true)
				event4 = EventAggregator::Event.new(event_type + "4", data, false, false)

				allow(event2).to receive(:clone).and_return(event2)
				allow(event4).to receive(:clone).and_return(event4)

				expect(callback).to receive(:call).with(event1)
				expect(callback).to receive(:call).with(event2)
				expect(callback).to receive(:call).with(event3)
				expect(callback).to receive(:call).with(event4)

				expect{EventAggregator::Aggregator.event_publish(event1)}.to_not raise_error
				expect{EventAggregator::Aggregator.event_publish(event2)}.to_not raise_error
				expect{EventAggregator::Aggregator.event_publish(event3)}.to_not raise_error
				expect{EventAggregator::Aggregator.event_publish(event4)}.to_not raise_error
			end
		end
		describe 'illegal parameters' do
			it 'non-event type' do
				expect{EventAggregator::Aggregator.event_publish("string")}.to raise_error
				expect{EventAggregator::Aggregator.event_publish(1)}       .to raise_error
				expect{EventAggregator::Aggregator.event_publish(listener)}.to raise_error
				expect{EventAggregator::Aggregator.event_publish()}        .to raise_error
				expect{EventAggregator::Aggregator.event_publish(nil)}     .to raise_error
			end
		end
		describe 'consisten_data behaviour' do
			it 'uses same object when true' do
				listener2 = listener_class.new
				callback1 = lambda{|data|}
				callback2 = lambda{|data|}

				EventAggregator::Aggregator.register(listener, event_type, callback1)
				EventAggregator::Aggregator.register(listener2, event_type, callback2)

				event = EventAggregator::Event.new(event_type, data, false, true)

				expect(callback1).to receive(:call) {|arg| expect(arg).to equal(data)}
				expect(callback2).to receive(:call) {|arg| expect(arg).to equal(data)}

				EventAggregator::Aggregator.event_publish(event)
			end
			it 'uses different objects when false' do
				listener2 = listener_class.new
				callback1 = lambda{|data| data = "no"}
				callback2 = lambda{|data| data = "no"}

				EventAggregator::Aggregator.register(listener, event_type, callback1)
				EventAggregator::Aggregator.register(listener2, event_type, callback2)

				event = EventAggregator::Event.new(event_type, data, false, false)

				expect(callback1).to receive(:call) {|arg| expect(arg).to_not equal(data)}
				expect(callback2).to receive(:call) {|arg| expect(arg).to_not equal(data)}

				EventAggregator::Aggregator.event_publish(event)
			end
			it 'objects have same values when false' do
				listener2 = listener_class.new
				callback1 = lambda{|data| data = "no"}
				callback2 = lambda{|data| data = "no"}

				EventAggregator::Aggregator.register(listener, event_type, callback1)
				EventAggregator::Aggregator.register(listener2, event_type, callback2)

				event = EventAggregator::Event.new(event_type, data, false, false)

				expect(callback1).to receive(:call) {|arg| expect(arg).to eq(data)}
				expect(callback2).to receive(:call) {|arg| expect(arg).to eq(data)}

				EventAggregator::Aggregator.event_publish(event)
			end
		end
	end

	describe "self.register_all" do
		describe 'legal parameters' do
			it "accepts different callback types" do
				expect{EventAggregator::Aggregator.register_all(listener, lambda { |args| })}.to_not raise_error
				expect{EventAggregator::Aggregator.register_all(listener, Proc.new{ |args| })}.to_not raise_error

				listener2 = (Class.new { include EventAggregator::Listener; def testmethod(data); end;}).new

				expect{EventAggregator::Aggregator.register_all(listener2, :testmethod)}.to_not raise_error
				expect{EventAggregator::Aggregator.register_all(listener2, "testmethod")}.to_not raise_error
			end

			it 'registered at correct place' do
				EventAggregator::Aggregator.register_all(listener, callback)
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners_all)).to include(listener)
			end

			it 'not register same listener multiple times' do
				EventAggregator::Aggregator.register_all(listener, callback)
				expect{EventAggregator::Aggregator.register_all(listener, callback)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners_all)}
			end
			it "overwrite previous callback" do
				callback2 = lambda { |data| }
				EventAggregator::Aggregator.register_all(listener, callback)
				EventAggregator::Aggregator.register_all(listener, callback2)
				
				expect(callback).to_not receive(:call)
				expect(callback2).to receive(:call)

				EventAggregator::Aggregator.event_publish(EventAggregator::Event.new(event_type, data))
			end
		end
		describe 'illegal parameters' do
			it 'listener raise error' do
				expect{EventAggregator::Aggregator.register_all(nil,                                   callback)}.to raise_error
				#expect{EventAggregator::Aggregator.register_all(EventAggregator::Event.new("a","b"), callback)}.to raise_error #These should no longer raise any error. We don't care what teh listener looks like
				#expect{EventAggregator::Aggregator.register_all(random_string,                         callback)}.to raise_error #These should no longer raise any error. We don't care what teh listener looks like
				#expect{EventAggregator::Aggregator.register_all(random_number,                         callback)}.to raise_error #These should no longer raise any error. We don't care what teh listener looks like
				#expect{EventAggregator::Aggregator.register_all(2.0,                                   callback)}.to raise_error #These should no longer raise any error. We don't care what teh listener looks like
			end
			it 'callback raise error' do
				expect{EventAggregator::Aggregator.register_all(listener, nil                                  )}.to raise_error
				expect{EventAggregator::Aggregator.register_all(listener, EventAggregator::Event.new("a","b"))}.to raise_error
				expect{EventAggregator::Aggregator.register_all(listener, random_string                        )}.to raise_error
				expect{EventAggregator::Aggregator.register_all(listener, random_number                        )}.to raise_error
				expect{EventAggregator::Aggregator.register_all(listener, 2.0                                  )}.to raise_error
			end
			it 'raises error on illegal callback name' do
				listener_2 =  (Class.new { include EventAggregator::Listener; def test(data); end }).new
				expect{EventAggregator::Aggregator.register_all(listener_2, "test2")}.to raise_error
			end
		end
	end

	describe "self.reset" do
		it 'removes all listenes' do
			EventAggregator::Aggregator.register(listener, event_type, callback)
			EventAggregator::Aggregator.register_all(listener, callback)
			EventAggregator::Aggregator.translate_event_with(event_type, event_type + " different")
			EventAggregator::Aggregator.register_producer(producer, event_type, callback)

			EventAggregator::Aggregator.reset

			expect(EventAggregator::Aggregator.class_variable_get(:@@listeners))          .to be_empty
			expect(EventAggregator::Aggregator.class_variable_get(:@@listeners_all))      .to be_empty
			expect(EventAggregator::Aggregator.class_variable_get(:@@event_translation)).to be_empty
			expect(EventAggregator::Aggregator.class_variable_get(:@@producers))          .to be_empty
		end

		it 'listener not receive events' do
			listener2 = listener_class.new
			callback2 = lambda{|data|}
			event = EventAggregator::Event.new(event_type, data)
			EventAggregator::Aggregator.register(listener, event_type, callback)
			EventAggregator::Aggregator.register_all(listener2, callback2)

			EventAggregator::Aggregator.reset

			expect(callback).to_not receive(:call)
			expect(callback2).to_not receive(:call)

			EventAggregator::Aggregator.event_publish(event)
		end
		it "producers not responding" do
			EventAggregator::Aggregator.register_producer(producer, event_type, callback)
			event = EventAggregator::Event.new(event_type, data)

			EventAggregator::Aggregator.reset

			expect(callback).to_not receive(:call)

			EventAggregator::Aggregator.event_request(event)
		end
	end

	describe "self.translate_event_with" do
		describe 'legal parameters' do
			it "creates new event from type" do
				EventAggregator::Aggregator.register(listener, event_type + " different", callback)
				event = EventAggregator::Event.new(event_type, data)

				EventAggregator::Aggregator.translate_event_with(event_type, event_type + " different")

				expect(callback).to receive(:call).with(data)

				EventAggregator::Aggregator.event_publish(event)
			end

			it "listener receives transformed data" do
				EventAggregator::Aggregator.register(listener, event_type + " different", callback)
				event = EventAggregator::Event.new(event_type, "data")

				EventAggregator::Aggregator.translate_event_with(event_type, event_type + " different", lambda{|data| "other data"})

				expect(callback).to receive(:call).with("other data")

				EventAggregator::Aggregator.event_publish(event)
			end

			it "multiple assigns not change list" do
				event = EventAggregator::Event.new(event_type, data)

				EventAggregator::Aggregator.translate_event_with(event_type, event_type + " different")

				expect{EventAggregator::Aggregator.translate_event_with(event_type, event_type + " different")}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@event_translation)}
			end

			it "multiple assigns not publish several events" do
				EventAggregator::Aggregator.register(listener, event_type + " different", callback)
				event = EventAggregator::Event.new(event_type, data)

				EventAggregator::Aggregator.translate_event_with(event_type, event_type + " different")
				EventAggregator::Aggregator.translate_event_with(event_type, event_type + " different")

				expect(callback).to receive(:call).with(data).once

				EventAggregator::Aggregator.event_publish(event)
			end

			it "multiple assigns to update callback" do
				EventAggregator::Aggregator.register(listener, event_type + " different", callback)
				event = EventAggregator::Event.new(event_type, "data")

				EventAggregator::Aggregator.translate_event_with(event_type, event_type + " different")
				EventAggregator::Aggregator.translate_event_with(event_type, event_type + " different", lambda{|data| "changed data"})

				expect(callback).to receive(:call).with("changed data").once

				EventAggregator::Aggregator.event_publish(event)
			end
		end
		describe 'illegal parameters' do
			it "callback raise error" do
				expect{EventAggregator::Aggregator.translate_event_with(event_type, event_type + " different", nil)}                 .to raise_error
				expect{EventAggregator::Aggregator.translate_event_with(event_type, event_type + " different", random_number)}       .to raise_error
				expect{EventAggregator::Aggregator.translate_event_with(event_type, event_type + " different", random_string)}       .to raise_error
				expect{EventAggregator::Aggregator.translate_event_with(event_type, event_type + " different", Object.new)}          .to raise_error
				expect{EventAggregator::Aggregator.translate_event_with(event_type, event_type + " different", lambda{})}            .to raise_error
				expect{EventAggregator::Aggregator.translate_event_with(event_type, event_type + " different", lambda{ "whatever" })}.to raise_error
			end

			it "event type nil raise error" do
				expect{EventAggregator::Aggregator.translate_event_with(nil,          event_type)}.to raise_error
				expect{EventAggregator::Aggregator.translate_event_with(event_type, nil)}         .to raise_error
				expect{EventAggregator::Aggregator.translate_event_with(nil,          nil)}         .to raise_error
			end

			#Very VERY important that these raise errors!
			it "equal arguments no callback raise error" do
				expect{EventAggregator::Aggregator.translate_event_with(event_type,  event_type)} .to raise_error
				expect{EventAggregator::Aggregator.translate_event_with(random_string, random_string)}.to raise_error
				expect{EventAggregator::Aggregator.translate_event_with(random_number, random_number)}.to raise_error
				expect{EventAggregator::Aggregator.translate_event_with(random_number, random_number)}.to raise_error
				expect{EventAggregator::Aggregator.translate_event_with("string",      "string")}     .to raise_error
				expect{EventAggregator::Aggregator.translate_event_with(1,             1)}            .to raise_error
			end

			it "equal arguments with callback raise error" do
				expect{EventAggregator::Aggregator.translate_event_with(event_type,  event_type,  callback)}.to raise_error
				expect{EventAggregator::Aggregator.translate_event_with(random_string, random_string, callback)}.to raise_error
				expect{EventAggregator::Aggregator.translate_event_with(random_number, random_number, callback)}.to raise_error
				expect{EventAggregator::Aggregator.translate_event_with(random_number, random_number, callback)}.to raise_error
				expect{EventAggregator::Aggregator.translate_event_with("string",      "string",      callback)}.to raise_error
				expect{EventAggregator::Aggregator.translate_event_with(1,             1,             callback)}.to raise_error
			end
		end
	end

	describe "self.register_producer" do
		describe 'legal parameters' do
			it "accepts different callback types" do
				expect{EventAggregator::Aggregator.register_producer(producer, event_type, lambda { |args| })}.to_not raise_error
				expect{EventAggregator::Aggregator.register_producer(producer, event_type, Proc.new{ |args| })}.to_not raise_error

				producer2 = (Class.new { include EventAggregator::Listener; def testmethod(data); end;}).new

				expect{EventAggregator::Aggregator.register_producer(producer2, event_type, :testmethod)}.to_not raise_error
				expect{EventAggregator::Aggregator.register_producer(producer2, event_type, "testmethod")}.to_not raise_error
			end
		end

		describe 'illegal parameters' do
			it 'callback raise error' do
				expect{EventAggregator::Aggregator.register_producer(producer, event_type, nil                                  )}.to raise_error
				expect{EventAggregator::Aggregator.register_producer(producer, event_type, EventAggregator::Event.new("a","b"))}.to raise_error
				expect{EventAggregator::Aggregator.register_producer(producer, event_type, random_string                        )}.to raise_error
				expect{EventAggregator::Aggregator.register_producer(producer, event_type, random_number                        )}.to raise_error
				expect{EventAggregator::Aggregator.register_producer(producer, event_type, 2.0                                  )}.to raise_error
			end
		end
	end

	describe "self.unregister_producer" do
		it "producers not responding" do
			EventAggregator::Aggregator.register_producer(producer, event_type, callback)
			event = EventAggregator::Event.new(event_type, data)

			EventAggregator::Aggregator.unregister_producer(event_type)

			expect(callback).to_not receive(:call)

			EventAggregator::Aggregator.event_request(event)
		end
	end


	describe "self.event_request" do
		describe 'legal parameters' do
			it 'run correct callback' do
				EventAggregator::Aggregator.register_producer(producer, event_type, callback)
				event = EventAggregator::Event.new(event_type, data)

				expect(callback).to receive(:call).with(data)

				EventAggregator::Aggregator.event_request(event)
			end
			it 'not run incorrect callback' do
				event_type2 = event_type + " different"

				EventAggregator::Aggregator.register_producer(producer, event_type, callback)
				event = EventAggregator::Event.new(event_type2, data)

				expect(callback).to_not receive(:call).with(data)

				EventAggregator::Aggregator.event_request(event)
			end

			it 'run correct callback in list' do
				event_type2 = event_type + " different"

				callback2 = lambda{|data|}

				EventAggregator::Aggregator.register_producer(producer, event_type, callback)
				EventAggregator::Aggregator.register_producer(producer, event_type2, callback2)

				event = EventAggregator::Event.new(event_type, data)

				expect(callback).to receive(:call).with(data)
				expect(callback2).to_not receive(:call)

				EventAggregator::Aggregator.event_request(event)
			end

		end
		describe 'illegal parameters' do
			it 'non-event type' do
				expect{EventAggregator::Aggregator.event_request("string")}.to raise_error
				expect{EventAggregator::Aggregator.event_request(1)}       .to raise_error
				expect{EventAggregator::Aggregator.event_request(listener)}.to raise_error
				expect{EventAggregator::Aggregator.event_request()}        .to raise_error
				expect{EventAggregator::Aggregator.event_request(nil)}     .to raise_error
			end
		end
	end

	describe 'propagates fully' do
		class TestClassSingle
			include EventAggregator::Listener

			def initialize
				event_type_register("event_type", method(:test_method))
			end

			def test_method(data)
				self.self_called(data)
			end
			def self_called(data)
			end
		end

		class TestClassAll
			include EventAggregator::Listener

			def initialize
				event_type_register_all(method(:test_method))
			end

			def test_method(data)
				self.self_called(data)
			end
			def self_called(data)
			end
		end

		it "calls method on test class single" do
			test_class = TestClassSingle.new
			expect(test_class).to receive(:self_called).with(data)
			event = EventAggregator::Event.new("event_type", data)
			EventAggregator::Aggregator.event_publish(event)
		end

		it "calls method on test class all" do
			test_class = TestClassAll.new
			event = EventAggregator::Event.new("event_type", data)
			expect(test_class).to receive(:self_called){|e| expect(e.event_type).to eq("event_type") and expect(e.data).to eq(data)}
			EventAggregator::Aggregator.event_publish(event)
		end

		it "calls method on test class single full-stack" do
			test_class = TestClassSingle.new
			expect(test_class).to receive(:self_called).with(data)
			event = EventAggregator::Event.new("event_type", data)
			event.publish
		end

		it "calls method on test class all full-stack" do
			test_class = TestClassAll.new
			event = EventAggregator::Event.new("event_type", data)
			expect(test_class).to receive(:self_called){|e| expect(e.event_type).to eq("event_type") and expect(e.data).to eq(data)}
			event.publish
		end
		it "calls method on mulitple" do
			test_class = TestClassAll.new
			test_class2 = TestClassSingle.new
			event = EventAggregator::Event.new("event_type", data)
			expect(test_class).to receive(:self_called){|e| expect(e.event_type).to eq("event_type") and expect(e.data).to eq(data)}
			expect(test_class2).to receive(:self_called).with(data)
			event.publish
		end
	end
end