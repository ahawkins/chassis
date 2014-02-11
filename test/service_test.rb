require_relative 'test_helper'

class ServiceTest < MiniTest::Unit::TestCase
  def build(&block)
    Class.new Service, &block
  end

  def test_use_raises_an_error_if_unknown_implementation
    service = build do
      include Chassis.service
    end

    assert_raises Service::UnregisteredImplementationError do
      service.use :foo
    end
  end

  # def test_raises_an_error_if_method_not_implemented
  #   service = build do
  #     implements :add
  #   end
  #
  #   implementation = Class.new
  #
  #   service.register :test, implementation.new
  #   service.use :test
  #
  #   assert_raises Service::NotImplementedError do
  #     service.add 1, 2
  #   end
  # end
  #
  # def test_delegates_work_to_selected_implementation
  #   service = build do
  #     implements :add
  #   end
  #
  #   implementation = Class.new do
  #     def add(*numbers)
  #       numbers.inject(&:+)
  #     end
  #   end
  #
  #   service.register :test, implementation.new
  #   service.use :test
  #
  #   assert_equal 3, service.add(1, 2)
  # end
  #
  # def test_defines_an_up_query_method
  #   service = build do
  #     implements :add
  #   end
  #
  #   implementation = Class.new do
  #     def up?
  #       true
  #     end
  #   end
  #
  #   service.register :test, implementation.new
  #   service.use :test
  #
  #   assert service.up?
  #   refute service.down?
  # end
  #
  # def test_generates_a_null_implementation_that_returns_the_arguments_by_default
  #   service = build do
  #     implements :add
  #   end
  #
  #   assert_equal [1,2], service.add(1,2)
  # end
  #
  # def test_can_implement_multiple_methods_at_once
  #   service = build do
  #     implements :foo, :bar
  #   end
  #
  #   implementation = Class.new do
  #     def foo
  #       :foo
  #     end
  #
  #     def bar
  #       :bar
  #     end
  #   end
  #
  #   service.register :test, implementation.new
  #   service.use :test
  #
  #   assert_equal :foo, service.foo
  #   assert_equal :bar, service.bar
  # end
end
