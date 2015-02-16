# EventAggregator gem


[![Gem Version](https://badge.fury.io/rb/event_aggregator.png)][gem]
[![Build Status](https://travis-ci.org/stephan-nordnes-eriksen/event_aggregator.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/stephan-nordnes-eriksen/event_aggregator.png)][gemnasium]
[![Code Climate](https://codeclimate.com/github/stephan-nordnes-eriksen/event_aggregator.png)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/stephan-nordnes-eriksen/event_aggregator/badge.png)][coveralls]
[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/stephan-nordnes-eriksen/event_aggregator/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

[gem]: https://rubygems.org/gems/event_aggregator
[travis]: https://travis-ci.org/stephan-nordnes-eriksen/event_aggregator
[gemnasium]: https://gemnasium.com/stephan-nordnes-eriksen/event_aggregator
[codeclimate]: https://codeclimate.com/github/stephan-nordnes-eriksen/event_aggregator
[coveralls]: https://coveralls.io/r/stephan-nordnes-eriksen/event_aggregator


The gem 'event_aggregator' is designed for use with the event aggregator pattern in Ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'event_aggregator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install event_aggregator

## Usage

Version 2.X. For version 1.X see below

	#!/usr/bin/ruby

	require "rubygems"
	require "event_aggregator"

	class Foo
		#The receiving method is used to register which events you want to receive when they are "published" 
		#Multiple event types can be chained to the same callback.
		receiving "foo", "foo2", "foo3", "...etc.", lambda{|data| puts data }
		receiving "bar", :handle_event

		#The responding method is used when your class answers a "request" from another class.
		#responding also allows multiple event types to be chained.
		#Note: There can only exist one object in the world which answers a specific type of request. The most recent registered object becomes the one who answers to the given event request.
		responding "speed of light", "C", lambda{|data| return 299_792_458 }
		responding "current IP", "IP", :ip_address

		def handle_event(data)
			puts "Event is handled:"
			puts data
		end

		#Current design choices dictates that you must have one argument in all callbacks for both receiving and responding.
		def ip_address(data)
			return "magically get IP address here"
		end
	end

	f = Foo.new

	#Events are published to the world. These events are asynchronous by default.
	EventAggregator::Event.new("foo", "some data").publish
	#=> some data
	EA::Event.new("bar", 1).publish
	#=> Event is handled:
	#=> 1
	EA::E.new("foo3", "data").publish
	#=> []
	#TODO: The below is currently un-implemented
	f.foo_unregister("foo2")
	EA::E.new("foo2", "data").publish
	#=> []

	#The world is queried for the following. These events are synchroneus by default.
	EA::E.new("speed of light", nil).request
	#=> 299792458
	EA::E.new("speed of sound", nil).request
	#=> nil
	
	#The results can be stored to variables because the request is synchroneus.
	c = EA::E.new("C", nil).request


Version 1.X:

	#!/usr/bin/ruby

	require "rubygems"
	require "event_aggregator"

	class Foo
		include EventAggregator::Listener
		def initialize()
			event_type_register( "foo", lambda{|data| puts data } )

			event_type_register( "foo2", method(:handle_event) )
		end

		def handle_event(data)
			puts data
		end
		
		def foo_unregister(*args)
			event_type_unregister(*args)
		end
	end

	f = Foo.new

	EventAggregator::Event.new("foo", "bar").publish
	#=> bar
	EventAggregator::Event.new("foo2", "data").publish
	#=> data
	EventAggregator::Event.new("foo3", "data").publish
	#=> []
	f.foo_unregister("foo2")
	EventAggregator::Event.new("foo2", "data").publish
	#=> []
	
	#Possible outcome:
	EventAggregator::Event.new("foo", "data").publish
	EventAggregator::Event.new("foo", "data2").publish
	#=> data2
	#=> data

### IMPORTANT: Asynchronous by Default
Event.publish is asynchronous by default. This means that if you run event_aggregator in a script that terminates, there is a chance that the script will terminate before the workers have processed the events. This might cause errors.

A simple way to get around this problem is to do the following:

	#....setup...
	EventAggregator::Event.new("foo2", "data").publish

	gets #This will wait for user input.

To make the event processing synchronous (not recommended) use the following:

	EventAggregator::Event.new("foo", "data", false).publish
	#=> data

The event data is duplicated by default for each of the receiving listeners. To force the same object for all listeners, set the consisten_data property to true.

	EventAggregator::Event.new("foo", "data", true, true).publish
	
This enables the following:

	class Foo
		include EventAggregator::Listener
		def initialize()
			event_type_register( "foo", lambda{|data| data << " bar" } )
		end
	end

	f1 = Foo.new
	f2 = Foo.new
	data = "foo"
	
	EventAggregator::Event.new("foo", data, true, false).publish

	puts data 
	#=> "foo"

	EventAggregator::Event.new("foo", data, true, true).publish
	
	puts data
	#=> "foo bar bar"

	EventAggregator::Event.new("foo", data, true, true).publish
	
	puts data
	#=> "foo bar bar bar bar"


## Producers
In version 1.1+ the concept of producers are added. They are blocks or methods that responds to requests. A producer must be registered, which is done like this:

	#listener is an instance of a class that includes EventAggregator::Listener, similar to the Foo class above.
	listener.producer_register("MultiplyByTwo", lambda{|data| return data*2})

Then, somewhere in your code, you can do the following:

	number = EventAggregator::Event.new("MultiplyByTwo", 3).request
	puts number
	# => 6

The producers are a good way to abstract away the retrieval of certain information.

Note: Event reqests are always blocking.

## Event translation
In version 1.1+ the concept of event translation is added. This allows you to have events on a specific type spawn other events. To translate event type "type_1" into "type_2" you do:
	
	#Anywhere in your code
	EventAggregator::Aggregator.translate_event_with("type_1", "type_2")

It is also possible to transform the data in the conversion. To double the data value between "type_1" and "type_2" you do:

	EventAggregator::Aggregator.translate_event_with("type_1", "type_2", lambda{|data| data*2})

This is often very usefull when you have one module that has a specific task, and it should be truly independent of other objects, even the event type they produce. The event translation allows you to have one file where you list all translations to give you a good overview and high maintainability.

## Usage Considerations
All events are processed asynchronous by default. This means that there might be raise conditions in your code. 

If you force synchronous event publishing you should take extra care of where in your code you produce new events. You can very easily create infinite loops where events are published and consumed by the same listener. Because of this it is advised not to produce events within the callback for the listener, even when using asynchronous event publishing. Another good rule is never to produce events of the same type as those you listen to. This does not completely guard you, as there can still exist loops between two or more listeners.

## About Event Aggregators
An event aggregator is essentially a event passing service that aims at decoupling objects in your code. This is achieved with events that has a type and some data. A event might be produced when an event, or other condition, occurs. When such conditions occurs a event can be produced with all relevant data in it. This event can then be published. The event will then be distributed to all other objects that want to receive this event type. This way the object or class that produced the event do not need to be aware of every other object that might be interested in the condition that just occurred. It also removes the need for this class to implement any consumer producer pattern or other similar methods to solving this problem. With an event aggregator the listener, the receiver of the event, does not need to know that the sender even exists. This will remove a lot of bug-producing couplings between objects and help your code become cleaner.

For more information see: http://martinfowler.com/eaaDev/EventAggregator.html 

Or: https://www.google.com/#q=event+aggregator

## Todo:
 - Improving the readme and documentation in the gem.

## Versioning Standard:
Using Semantic Versioning - http://semver.org/
### Versioning Summary

#### 0.0.X - Patch
	Small updates and patches that are backwards-compatible. Updating from 0.0.X -> 0.0.Y should not break your code.
#### 0.X - Minor
	Adding functionality and changes that are backwards-compatible. Updating from 0.X -> 0.Y should not break your code.
#### X - Major
	Architectural changes and other major changes that alter the API. Updating from X -> Y will most likely break your code.
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
