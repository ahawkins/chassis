require_relative '../test_helper'
require 'chassis/core_ext/string'

class StringCoreExtTest < MiniTest::Unit::TestCase
  def test_underscore
    assert_equal('foo_bar', 'FooBar'.underscore)
  end

  def test_demodulize
    assert_equal('Bar', 'Foo::Bar'.demodulize)
  end

  def test_constantize
    assert_equal self.class, self.class.name.constantize
  end
end
