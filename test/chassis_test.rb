require_relative 'test_helper'

class ChassisTest < MiniTest::Unit::TestCase
  def test_it_should_define_a_version
    assert Chassis::VERSION
  end
end
