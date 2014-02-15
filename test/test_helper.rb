ENV['RACK_ENV'] = 'test'

require 'bundler/setup'
require 'chassis'
require 'minitest/autorun'
require 'rack/test'
require 'mocha/setup'

require 'stringio'
require 'pathname'

class MiniTest::Unit::TestCase
  def tmp_path
    root.join 'tmp'
  end

  def root
    Pathname.new(File.expand_path '../../', __FILE__)
  end
end
