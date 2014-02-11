ENV['RACK_ENV'] = 'test'

require 'bundler/setup'
require 'chassis'
require 'minitest/autorun'
require 'minitest/hell'
require 'rack/test'
require 'mocha/setup'

require 'stringio'
