require_relative 'test_helper'

class ErrorTest < MiniTest::Unit::TestCase
  def test_delegates_to_tnt
    klass = Chassis.error do |foo|
      "#{foo} bar"
    end

    error = klass.new "Adam"
    assert_equal "Adam bar", error.message
  end
end
