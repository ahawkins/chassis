require_relative '../test_helper'

class NullAdapterTest < MiniTest::Unit::TestCase
  Person = Struct.new :name do
    attr_accessor :id
  end

  attr_reader :adapter

  def setup
    @adapter = Chassis::Repo::NullAdapter.new
  end

  def test_create_sets_the_id
    person = Person.new 'ahawkins'
    adapter.create person

    assert person.id, "Adapter must set the ID after creating"
  end

  def test_all_returns_an_empty_array
    assert_equal [], adapter.all(Person)
  end

  def test_implements_required_interface
    assert_respond_to adapter, :update
    assert_respond_to adapter, :delete
    assert_respond_to adapter, :find
    assert_respond_to adapter, :all
    assert_respond_to adapter, :count
    assert_respond_to adapter, :first
    assert_respond_to adapter, :last
    assert_respond_to adapter, :sample
    assert_respond_to adapter, :query
    assert_respond_to adapter, :graph_query
    assert_respond_to adapter, :graph_query
    assert_respond_to adapter, :clear
  end

  def test_count_returns_no
    assert_equal 0, adapter.count(Person)
  end

  def test_first_and_last_return_nil
    assert_nil adapter.first(Person)
    assert_nil adapter.first(Person)
  end
end
