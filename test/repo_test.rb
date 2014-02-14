require_relative 'test_helper'

class RepoTest < MiniTest::Unit::TestCase
  class TestAdapter < Chassis::Repo::InMemoryAdapter
    def query_test_empty_array_query(klass, q)
      [ ]
    end

    def query_test_nil_query(klass, q)
      nil
    end
  end

  TestEmptyArrayQuery = Struct.new :foo
  TestNilQuery = Struct.new :foo
  Person = Struct.new :name

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
end
