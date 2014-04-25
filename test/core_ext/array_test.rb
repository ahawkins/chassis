require_relative '../test_helper'
require 'chassis/core_ext/array'

class ArrayCoreExtTest < MiniTest::Unit::TestCase
  def test_extract_options!
    assert_equal({}, [].extract_options!)
  end
end
