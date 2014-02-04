require_relative 'test_helper'

class ProxTest < MiniTest::Unit::TestCase
  def test_prox_is_assigned_to_proxy
    assert_equal Chassis::Proxy, Prox
  end
end
