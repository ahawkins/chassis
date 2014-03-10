require_relative 'test_helper'

class ErrorTest < MiniTest::Unit::TestCase
  def test_error_builder_sets_the_message_from_the_args
    klass = Chassis.error do |foo|
      "#{foo} bar"
    end

    error = klass.new "Adam"
    assert_equal "Adam bar", error.message
  end

  def test_argument_is_not_required
    klass = Chassis.error NotImplementedError do
      "super duper!"
    end

    error = klass.new
    assert_equal "super duper!", error.message
  end

  def test_simple_failure_messages_can_be_given_as_the_argument
    klass = Chassis.error "test error"

    error = klass.new
    assert_equal "test error", error.message
  end

  def test_errors_without_arguments_can_be_used_like_normal
    klass = Chassis.error

    error = assert_raises klass do
      fail klass, "test"
    end

    assert_equal 'test', error.message

    assert_raises klass do
      fail klass
    end
  end
end
