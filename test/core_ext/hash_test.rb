require_relative '../test_helper'
require 'chassis/core_ext/hash'

class HashCoreExtTest < MiniTest::Unit::TestCase
  def test_symbolize
    assert_equal({ foo: 'bar' }, { 'foo' => 'bar' }.symbolize)
  end
end
