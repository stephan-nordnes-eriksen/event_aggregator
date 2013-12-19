require 'factory_girl'
require 'faker'
require 'event_aggregator'


# Public: Not really used. Might not be needed at all. The same 
# 		  goes for FactoryGirl in general. Might not be needed.
#
class DummyListener
	include EventAggregator::Listener
end

FactoryGirl.define do	
	factory :listener, class: DummyListener do

	end
	factory :message do
		message_type { Faker::Name.name }
		data { Faker::Commerce.product_name } #TODO: This bracket should be unnescecary
		#initialize_with(Faker::Name.name, Faker::Name.name)
	end
end