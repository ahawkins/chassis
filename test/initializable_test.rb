require_relative 'test_helper'

class InitializableTest < MiniTest::Unit::TestCase
  def test_uses_lift
    assert_equal Lift, Chassis::Initializable
  end
end
