# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chassis/version'

Gem::Specification.new do |spec|
  spec.name          = "chassis"
  spec.version       = Chassis::VERSION
  spec.authors       = ["ahawkins"]
  spec.email         = ["adam@hawkins.io"]
  spec.description   = %q{TODO: Write a gem description}
  spec.summary       = %q{TODO: Write a gem summary}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sinatra"
  spec.add_dependency "rack-contrib"
  spec.add_dependency "multi_json"
  spec.add_dependency "manifold"
  spec.add_dependency "prox"
  spec.add_dependency "harness"
  spec.add_dependency "harness-rack"
  spec.add_dependency "virtus", "1.0.0.rc2"
  spec.add_dependency "virtus-dirty"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "simplecov"
end
