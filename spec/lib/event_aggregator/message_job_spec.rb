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
			it "should recover from failing callback" do
				expect(callback).to receive(:call).and_raise("error")
				allow(STDERR).to receive(:puts)
				expect{message_job.perform(data,callback)}.to_not raise_error
			end
		end
		describe 'illegal parameters' do
			it 'should never be passed to MessageJob' do
				expect(true).to eq(true)
			end
			it "should print to STDERR on illegal callback type" do
				allow(STDERR).to receive(:puts)
				expect(STDERR).to receive(:puts).with("Error is probably due to invalid callback. No source location found.")
				
				expect{message_job.perform(data,"callback")}.to_not raise_error
			end
		end
	end
end
