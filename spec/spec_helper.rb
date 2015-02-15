require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require "rubygems"
require "bundler/setup"
require 'rspec'
#require 'rack/test'
require "faker"
require "event_aggregator"
#require "sucker_punch/testing/inline"
# require 'coveralls'

# Coveralls.wear!



# class Thread::Pool
	
# 	# Public: Overriding the process-call of the thread::pool so we can do tests better
# 	def process (*args, &block)
# 		block.call(*args)
# 	end
# end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end


class EventAggregator::Aggregator

  def self.restart_pool
    @@pool.shutdown
    @@pool = Thread.pool(4)
  end

end