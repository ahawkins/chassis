require_relative 'test_helper'

class CircuitPanelTest < MiniTest::Unit::TestCase
  def test_circuit_method_returns_the_given_circuit
    panel = Chassis.circuit_panel do
      circuit :test, timeout: 10
    end.new

    circuit = panel.test
    assert_kind_of Breaker::Circuit, circuit
    assert_equal :test, circuit.name
  end

  def test_options_passed_to_circuit_are_set_on_the_circuit
    panel = Chassis.circuit_panel do
      circuit :test, timeout: 10
    end.new

    circuit = panel.test
    assert_equal 10, circuit.timeout
  end
end
