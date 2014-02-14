require_relative '../test_helper'

class NullImplementationTest < MiniTest::Unit::TestCase
  Person = Struct.new :name do
    attr_accessor :id
  end

  attr_reader :implementation

  def setup
    @implementation = Chassis::Repo::NullImplementation.new
  end

  def test_create_sets_the_id
    person = Person.new 'ahawkins'
    implementation.create person

    assert person.id, "Implementation must set the ID after creating"
  end

  def test_all_returns_an_empty_array
    assert_equal [], implementation.all(Person)
  end

  def test_implements_required_interface
    assert_respond_to implementation, :update
    assert_respond_to implementation, :delete
    assert_respond_to implementation, :find
    assert_respond_to implementation, :all
    assert_respond_to implementation, :count
    assert_respond_to implementation, :first
    assert_respond_to implementation, :last
    assert_respond_to implementation, :sample
    assert_respond_to implementation, :query
    assert_respond_to implementation, :graph_query
    assert_respond_to implementation, :graph_query
    assert_respond_to implementation, :clear
  end

  def test_count_returns_no
    assert_equal 0, implementation.count(Person)
  end

  def test_first_and_last_return_nil
    assert_nil implementation.first(Person)
    assert_nil implementation.first(Person)
  end
end
