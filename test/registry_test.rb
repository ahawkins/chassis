require_relative 'test_helper'

class RegistryTest < MiniTest::Unit::TestCase
  def test_can_get_and_set_values
    registry = Chassis::Registry.new
    registry[:foo] = 'bar'
    assert_equal registry.fetch(:foo), 'bar'
  end

  def test_fails_with_an_error_if_nothing_registred
    registry = Chassis::Registry.new
    assert_raises Chassis::UnregisteredError do
      registry.fetch :foo
    end
  end

  def test_can_be_cleared
    registry = Chassis::Registry.new
    registry[:foo] = 'bar'
    assert_equal registry.fetch(:foo), 'bar'
    registry.clear
    assert_raises Chassis::UnregisteredError do
      registry.fetch :foo
    end
  end
end
