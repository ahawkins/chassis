require_relative 'test_helper'

class InitializableTest < MiniTest::Unit::TestCase
  class Person
    include Chassis::Initializable

    attr_accessor :nick
  end

  def test_sets_attributes
    person = Person.new nick: 'ahawkins'
    assert_equal 'ahawkins', person.nick
  end

  def test_works_with_a_block
    person = Person.new do |person|
      person.nick = 'ahawkins'
    end

    assert_equal 'ahawkins', person.nick
  end
end
