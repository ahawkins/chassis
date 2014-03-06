require_relative 'test_helper'

class DelegateTest < MiniTest::Unit::TestCase
  class Delegator
    include Chassis.delegate(:add, to: :object)

    attr_reader :object

    def initialize(object)
      @object = object
    end
  end

  def test_methods_are_delegated
    delegate = Class.new do
      def add(number)
        number + 5
      end
    end.new

    delegator = Delegator.new delegate

    assert_equal 10, delegator.add(5)
  end

  def test_raises_an_error_if_no_object_to_delegate_to
    delegator = Delegator.new nil

    assert_raises Chassis::DelegationError do
      delegator.add 1
    end
  end

  def test_fails_with_an_error_if_nothing_to_delegate_to
    assert_raises ArgumentError do
      Class.new do
        include Chassis.delegate(:foo, :bar)
      end
    end
  end
end
