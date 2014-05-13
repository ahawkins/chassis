# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chassis/version'

Gem::Specification.new do |spec|
  spec.name          = "chassis"
  spec.version       = Chassis::VERSION
  spec.authors       = ["ahawkins"]
  spec.email         = ["adam@hawkins.io"]
  spec.description   = %q{A collection of modules and helpers for building mantainable Ruby applications}
  spec.summary       = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sinatra"
  spec.add_dependency "sinatra-contrib"
  spec.add_dependency "rack-contrib"
  spec.add_dependency "manifold"
  spec.add_dependency "prox"
  spec.add_dependency "harness"
  spec.add_dependency "harness-rack"
  spec.add_dependency "virtus"
  spec.add_dependency "virtus-dirty_attribute"
  spec.add_dependency "faraday", "~> 0.9.0"
  spec.add_dependency "logger-better"
  spec.add_dependency "breaker"
  spec.add_dependency "interchange"
  spec.add_dependency "tnt"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "redis"
end
