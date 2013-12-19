# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'event_aggregator/version'

Gem::Specification.new do |spec|
  spec.name          = "event_aggregator"
  spec.version       = EventAggregator::VERSION
  spec.authors       = ["Stephan Eriksen"]
  spec.email         = ["stephan.n.eriksen@gmail.com"]
  spec.description   = %q{A simple Ruby event aggregator.}
  spec.summary       = %q{Event aggregator for Ruby.}
  spec.homepage      = "https://github.com/stephan-nordnes-eriksen/event_aggregator"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', "~> 1.3"
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'factory_girl'
  spec.add_development_dependency 'faker'
end
