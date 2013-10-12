require_relative 'test_helper'

class HashInitializerTest < MiniTest::Unit::TestCase
  class Person
    include Chassis::HashInitializer

    attr_accessor :nick
  end

  def test_sets_attributes

  end
end
