require_relative 'test_helper'

class RepoTest < MiniTest::Unit::TestCase
  class TestAdapter < Chassis::MemoryRepo
    def query_test_empty_array_query(klass, q)
      [ ]
    end

    def query_test_nil_query(klass, q)
      nil
    end

    def query_person_by_name(klass, q)
      all(klass).find do |record|
        record.name == q.name
      end
    end

    def update(record)
      record.name = 'updated'
    end
  end

  CustomError = Class.new RuntimeError
  TestEmptyArrayQuery = Struct.new :foo
  TestNilQuery = Struct.new :foo
  PersonByName = Struct.new :name
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

  def test_query_bang_works_when_a_non_array_object_is_returned
    person = Person.new nil, 'ahawkins'
    repo.save person
    assert_equal person, repo.query!(Person, PersonByName.new('ahawkins'))
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
