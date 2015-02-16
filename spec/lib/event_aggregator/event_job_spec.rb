require 'spec_helper'

describe EventAggregator::EventJob do
	let(:callback)    { lambda{ |data| } }
	let(:data)        { Faker::Name.name }
	let(:event_job) { EventAggregator::EventJob.new }

	describe '.perform' do
		describe 'legal parameters' do
			it 'excute callback with data' do
				expect(callback).to receive(:call).with(data)
				
				event_job.perform(data, callback)
			end
			it "should recover from failing callback" do
				expect(callback).to receive(:call).and_raise("error")
				allow(STDERR).to receive(:puts)
				expect{event_job.perform(data,callback)}.to_not raise_error
			end
		end
		describe 'illegal parameters' do
			it 'should never be passed to EventJob' do
				expect(true).to eq(true)
			end
			it "should print to STDERR on illegal callback type" do
				allow(STDERR).to receive(:puts)
				expect(STDERR).to receive(:puts).with("Error is probably due to invalid callback. No source location found.")
				
				expect{event_job.perform(data,"callback")}.to_not raise_error
			end
		end
	end
end
