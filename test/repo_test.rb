require_relative 'test_helper'

class RepoTest < MiniTest::Unit::TestCase
  class TestAdapter < Chassis::Repo::InMemoryAdapter
    def query_test_empty_array_query(klass, q)
      [ ]
    end

    def query_test_nil_query(klass, q)
      nil
    end

    def update(record)
      record.name = 'updated'
    end
  end

  CustomError = Class.new RuntimeError
  TestEmptyArrayQuery = Struct.new :foo
  TestNilQuery = Struct.new :foo
  Person = Struct.new :id, :name

  def repo
    Chassis.repo
  end

  def setup
    repo.register :test, TestAdapter.new
    repo.use :test
  end

  def test_query_bang_raises_an_exception_if_empty
    assert_raises Chassis::NoQueryResultError do
      repo.query! Person, TestEmptyArrayQuery.new(:foo)
    end
  end

  def test_query_bang_raises_an_exception_if_nil
    assert_raises Chassis::NoQueryResultError do
      repo.query! Person, TestNilQuery.new(:foo)
    end
  end

  def test_query_bang_can_take_a_block_to_customize_exception
    assert_raises CustomError do
      repo.query! Person, TestNilQuery.new(:foo) do |klass, selector|
        fail CustomError
      end
    end
  end

  def test_save_creates_records_without_ids
    person = Person.new nil, 'ahawkins'
    repo.save person
    assert person.id
  end

  def test_save_updates_records_otherwise
    person = Person.new 1, 'ahawkins'
    repo.save person
    assert_equal 'updated', person.name
  end
end
