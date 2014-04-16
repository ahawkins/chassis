require_relative '../test_helper'

class RepoDelegationTest < MiniTest::Unit::TestCase
  class PersonRepo
    extend Chassis::Repo::Delegation

    def self.obj_class
      Person
    end
  end

  class SomethingSomething
    extend Chassis::Repo::Delegation
  end

  Person = Struct.new :name

  attr_reader :target, :person

  def repo
    PersonRepo
  end

  def setup
    @target = mock
    @person = Person.new 'ahawkins'
    Chassis::Repo.stubs(:default).returns(target)
  end

  def test_classes_that_dont_match_on_name_fail_with_a_helpful_error
    assert_raises Chassis::UnknownObjectClassError do
      SomethingSomething.object_class
    end
  end

  def test_find_delegates_to_the_target
    target.expects(:find).with(Person, 1)
    repo.find(1)
  end

  def test_delete_delegates_to_the_target
    target.expects(:delete).with(person)
    repo.delete(person)
  end

  def test_save_delegates_to_the_target
    target.expects(:save).with(person)
    repo.save(person)
  end

  def test_first_delegates_to_the_target
    target.expects(:first).with(Person)
    repo.first
  end

  def test_last_delegates_to_the_target
    target.expects(:last).with(Person)
    repo.last
  end

  def test_all_delegates_to_the_target
    target.expects(:all).with(Person)
    repo.all
  end

  def test_count_delegates_to_the_target
    target.expects(:count).with(Person)
    repo.count
  end

  def test_query_delegates_to_the_target
    target.expects(:query).with(Person, :foo)
    repo.query :foo
  end

  def test_query_bang__delegates_to_the_target
    target.expects(:query!).with(Person, :foo)
    repo.query! :foo
  end

  def test_graph_query_delegates_to_the_target
    target.expects(:graph_query).with(Person, :foo)
    repo.graph_query(:foo)
  end

  def test_sample_delegates_to_the_backend
    target.expects(:sample).with(Person)
    repo.sample
  end

  def test_empty_delegates_to_the_backend
    target.expects(:empty?).with(Person)
    repo.empty?
  end

  def test_lazy_returns_new_lazy_associations
    target.expects(:find).never
    person = repo.lazy 'ahawkins'
    assert_equal 'ahawkins', person.id
  end
end
