require 'spec_helper'

describe "Patches" do
	
	# let(:event_type) { Faker::Internet.password }
	let(:data) { Faker::Internet.password }
	
	before(:each) do
		Object.send(:remove_const, :Foo) if Object.constants.include?(:Foo)
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

		it "only call callback one time on receiving" do
			spy_hack = spy("hack")
			class Foo
				receiving "a", :test
				receiving "a", :test
				def test(a)
					a.hack()
				end
			end

			a = Foo.new
			expect(spy_hack).to receive(:hack).once
			EA::E.new("a",spy_hack).publish
		end

		it "only call callback one time on responding" do
			spy_hack2 = spy("hack")
			class Foo
				responding "b", :test
				responding "b", :test
				def test(a)
					a.hack()
				end
			end

			a = Foo.new
			expect(spy_hack2).to receive(:hack).once
			EA::E.new("b",spy_hack2).request
		end

		it "only call callback one time on receive_all" do
			spy_hack = spy("hack")

			class Foo
				receive_all :test
				receive_all :test
				def test(a)
					a.data.hack()
				end
			end

			a = Foo.new
			expect(spy_hack).to receive(:hack).once
			event = EA::E.new("a",spy_hack)
			event.publish



		end

		it "using multiple of the same does not raise error" do
			expect{
				class Foo
					responding Faker::Internet.password, lambda { |args|  }
					responding Faker::Internet.password, lambda { |args|  }
				end
				a = Foo.new
			}.to_not raise_error

			expect{
				class Foo
					receiving Faker::Internet.password, lambda { |args|  }
					receiving Faker::Internet.password, lambda { |args|  }
				end
				a = Foo.new
			}.to_not raise_error

			expect{
				class Foo
					receive_all Faker::Internet.password, lambda { |args|  }
					receive_all Faker::Internet.password, lambda { |args|  }
				end
				a = Foo.new
			}.to_not raise_error
		end



		it "using same callback name does not raise error" do
			expect{
				class Foo
					receiving "a", lambda { |args|  }
					receiving "a", lambda { |args|  }
				end
				a = Foo.new
			}.to_not raise_error

			expect{
				class Foo
					responding "a", lambda { |args|  }
					responding "a", lambda { |args|  }
				end
				a = Foo.new
			}.to_not raise_error

			expect{
				class Foo
					receive_all "a", lambda { |args|  }
					receive_all "a", lambda { |args|  }
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
			expect{
				class Foo
					receiving Faker::Internet.password, lambda { |args|  }
					responding Faker::Internet.password, lambda { |args|  }
					receive_all lambda { |args|  }
				end
				a = Foo.new
			}.to_not raise_error
		end

		it "gets callbacks correctly" do
			hack_spy = spy("hack spy")
			class Foo
				receiving "test type", lambda { |args|  }
				receiving "test type", :test

				responding "test type", lambda { |args|  }
				responding "test type", :test
				def test(arg)
					arg.hack() #For some reason i can't do expect(a).to receive(:test)
				end
			end
			a = Foo.new
			expect(hack_spy).to receive(:hack)
			EA::E.new("test type", hack_spy).publish

			expect(hack_spy).to receive(:hack)
			EA::E.new("test type", hack_spy).request
		end
	end
end