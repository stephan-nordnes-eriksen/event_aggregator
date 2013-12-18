# EventAggregator

#### Note: This is a very early release and subject to many changes. It is currently not tested propperly, and there are several issues ranging from potential dead-locks to upcoming refactoring.

The 'event_aggregator' gem is a gem for using the event aggregator pattern in Ruby. 

An event aggregator is essentially a message passing service that aims at decoupeling object communication and that lets 

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
			message_type_to_receive_add( "foo", lambda{|data| puts "bar" } )

			message_type_to_receive_add( "foo2", method(:handle_message) )
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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Todo:

 - Adding tests
 - Enable threaded message passing for higher performance. 
 - Improving the readme and documentation in the gem.
