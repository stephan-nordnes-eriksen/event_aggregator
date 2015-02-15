require 'spec_helper'

describe "Patches" do
	
	# let(:message_type) { Faker::Internet.password }
	let(:data) { Faker::Internet.password }
	
	before(:all) do
		EventAggregator::Aggregator.reset
	end

	after(:each) do
		EventAggregator::Aggregator.restart_pool
	end

	describe "legal parameters" do
		it "defining classes does not raise error" do
			expect{
				class Foo
				end
			}.to_not raise_error
		end
		
		it "instanciating classes does not raise errors" do
			expect{
				class Foo
				end
				a = Foo.new
			}.to_not raise_error
		end

		it "using receiving does not raise error" do
			expect{
				class Foo
					receiving Faker::Internet.password, lambda { |args|  }
				end
				a = Foo.new
			}.to_not raise_error
		end
		it "using receive_all does not raise error" do
			expect{
				class Foo
					receive_all Faker::Internet.password, lambda { |args|  }
				end
				a = Foo.new
			}.to_not raise_error
		end
		it "using responding does not raise error" do
			expect{
				class Foo
					responding Faker::Internet.password, lambda { |args|  }
				end
				a = Foo.new
			}.to_not raise_error
		end

		it "using multiple of the same does not raise error" do
			expect{
				class Foo
					responding Faker::Internet.password, lambda { |args|  }
					responding Faker::Internet.password, lambda { |args|  }
				end
				a = Foo.new
			}.to_not raise_error
			#TODO: for each type
		end



		it "using same callback name does not raise error" do
			expect{
				class Foo
					responding "a", lambda { |args|  }
					responding "a", lambda { |args|  }
				end
				a = Foo.new
			}.to_not raise_error
		end

		it "using method name works" do
			expect{
				class Foo
					responding Faker::Internet.password, "test"
					responding Faker::Internet.password, :test
					def test(arg)
					end
				end
				a = Foo.new
			}.to_not raise_error
		end

		it "multiple together does not raise error" do
			expect{
				class Foo
					receiving Faker::Internet.password, lambda { |args|  }
					responding Faker::Internet.password, lambda { |args|  }
				end
				a = Foo.new
			}.to_not raise_error
		end

		it "gets callbacks correctly" do
			hack_spy = spy("hack spy")
			class Foo
				# receiving "test type", lambda { |args|  }
				receiving "test type", :test

				# responding "test type", lambda { |args|  }
				responding "test type", :test
				def test(arg)
					arg.hack() #For some reason i can't do expect(a).to receive(:test)
				end
			end
			a = Foo.new
			expect(hack_spy).to receive(:hack)
			EA::M.new("test type", hack_spy).publish

			expect(hack_spy).to receive(:hack)
			EA::M.new("test type", hack_spy).request
		end
	end
end