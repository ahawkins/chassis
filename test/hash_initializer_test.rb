require_relative 'test_helper'

class HashInitializerTest < MiniTest::Unit::TestCase
  class Person
    include Chassis::HashInitializer

    attr_accessor :nick
  end

  def test_sets_attributes
    person = Person.new nick: 'ahawkins'
    assert_equal 'ahawkins', person.nick
  end
end
