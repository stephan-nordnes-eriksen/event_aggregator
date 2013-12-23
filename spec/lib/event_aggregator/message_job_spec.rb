require 'spec_helper'

describe EventAggregator::MessageJob do
	let(:callback)    { lambda{ |data| } }
	let(:data)        { Faker::Name.name }
	let(:message_job) { EventAggregator::MessageJob.new }

	describe '.perform' do
		describe 'legal parameters' do
			it 'excute callback with data' do
				expect(callback).to receive(:call).with(data)
				
				message_job.perform(data, callback)
			end
		end
		describe 'illegal parameters' do
			it 'raise error' do
				expect{message_job.perform(data, 2)}.to           raise_error
				expect{message_job.perform(data, "string")}.to    raise_error
				expect{message_job.perform(data, 2.0)}.to         raise_error
				expect{message_job.perform(data, message_job)}.to raise_error
				expect{message_job.perform(data, nil)}.to         raise_error
			end
		end
	end
end
