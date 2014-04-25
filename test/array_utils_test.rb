require_relative 'test_helper'

class ArrayUtilsTest < MiniTest::Unit::TestCase
  def utils
    Chassis::ArrayUtils
  end

  def test_extract_options_removes_options_hash_if_present
    args = ['foo', { bar: 'baz' }]
    options = utils.extract_options! args

    assert_equal({ bar: 'baz' }, options)
    assert_equal(%w(foo), args)
  end

  def test_extract_options_does_nothing_if_no_options
    args = %w(foo)
    options = utils.extract_options! args

    assert_equal({}, options)
    assert_equal(%w(foo), args)
  end
end
