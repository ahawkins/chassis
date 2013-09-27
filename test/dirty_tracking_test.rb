require_relative 'test_helper'

class DirtyTrackingTest < MiniTest::Unit::TestCase
  class Person
    include Chassis::DirtyTracking

    dirty_accessor :name

    def initialize(name = nil)
      self.name = name if name
      self.clean!
    end
  end

  def test_initializing_with_a_value_should_not_be_dirty
    person = Person.new 'Adam'
    refute person.dirty?
  end

  def test_setting_an_existing_value_marks_it_as_dirty
    person = Person.new 'Adam'
    refute person.dirty?

    person.name = 'Joe'
    assert person.dirty?
    assert person.name_dirty?

    assert_equal 'Adam', person.original_name
    assert_equal 'Adam', person.original_attributes[:name]

    assert_includes person.dirty_attributes, :name
  end

  def test_setting_a_value_after_init_saves_original_value
    person = Person.new
    refute person.dirty?

    person.name = 'Adam'
    assert person.dirty?
    assert person.name_dirty?

    assert_nil person.original_name
    assert_nil person.original_attributes[:name]
  end

  def test_objects_can_clean_themselves
    person = Person.new
    refute person.dirty?

    person.name = 'Adam'
    assert person.dirty?

    refute_empty person.dirty_attributes
    refute_empty person.original_attributes

    person.clean!

    refute person.dirty?
    assert_empty person.dirty_attributes
    assert_empty person.original_attributes
  end
end
