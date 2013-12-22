# EventAggregator gem

The gem 'event_aggregator' is designed for usie with the event aggregator pattern in Ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'event_aggregator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install event_aggregator

## Usage

	#!/usr/bin/ruby

	require "rubygems"
	require "event_aggregator"

	class Foo
		include EventAggregator::Listener
		def initialize()
			message_type_register( "foo", lambda{|data| puts "bar" } )

			message_type_register( "foo2", method(:handle_message) )
		end

		def handle_message(data)
			puts data
		end
	end

	f = Foo.new

	EventAggregator::Message.new("foo", "data").publish
	#=> bar
	EventAggregator::Message.new("foo2", "data").publish
	#=> data
	EventAggregator::Message.new("foo3", "data").publish
	#=> 
	f.message_type_unregister("foo2")
	EventAggregator::Message.new("foo2", "data").publish
	#=>
	
	EventAggregator::Message.new("foo2", "data").publish
	EventAggregator::Message.new("foo2", "data2").publish
	#=> data2
	#=> data

Message.publish is async by default. To make it synchroneus (not recommended) use the following:

	EventAggregator::Message.new("foo2", "data", false).publish
	#=> data

The message data is duplicated by default for each of the receiving listeners. To force the same object for all listeners, set the consisten_data property.

	EventAggregator::Message.new("foo2", "data", true, true).publish
	
This enables you to do the following:

	class Foo
		include EventAggregator::Listener
		def initialize()
			message_type_register( "foo", lambda{|data| data = data + " bar" } )
		end
	end

	f1 = Foo.new
	f2 = Foo.new
	data = "foo"

	EventAggregator::Message.new("foo", data).publish
	
	puts data
	#=> "foo bar bar"


## Usage Considerations
All messages are processed async by default. This means that there might be raise conditions in your code. 

If you force synchroneus message publishing you should take extra care of where in your code you produce new messages. You can very easily create infinite loops where messages are published and consumed by the same listener. Because of this it is adivised not to produce messages within the callback for the listener, even when using async message publishing. Another good rule is never to produce messages of the same type as those you listen to. This does not completely guard you, as there can still exist loops between two or more listeners.



### 0.0.X - Patch
	Small updates and patches that are backwards-compatible. Updating from 0.0.X -> 0.0.Y should not break your code.
### 0.X - Minor
	Adding functionality and changes that are backwards-compatible. Updating from 0.X -> 0.Y should not break your code.
### X - Major
	Architectural changes and other major changes that alter the API. Updating from X -> Y will most likely break your code.

## About Event Aggregators
An event aggregator is essentially a message passing service that aims at decoupeling objects in your code. This is achieved with messages that has a type and some data. A message might be produced when an event, or other condition, occurs within one object or class that might be of interest to thers. This object or class then put all relevant data into the message and publishes it. This message will then be distributed to all other objects that want to recieve this message type. This way the object or class that first got knowledge of the condition do not need to be aware of every other object that might be interested in knowing about this. It also removes the need for this class to implement any listeners and so forth. This way the listener, the receiver of the message, does not need to know that the sender even exists. This will help your code be a lot cleaner and remove a lot of bug-producing couplings between objects.

For more information see: http://martinfowler.com/eaaDev/EventAggregator.html 

Or: https://www.google.com/#q=event+aggregator

## Todo:
 - Improving the readme and documentation in the gem.

## Versioning Standard:
Using Semantic Versioning - http://semver.org/
### Versioning Summary
Given a version number MAJOR.MINOR.PATCH, increment the:

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
