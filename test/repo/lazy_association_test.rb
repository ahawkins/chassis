require_relative '../test_helper'

class LazyAssociationTest < MiniTest::Unit::TestCase
  class Person
    attr_reader :id, :name

    def initialize(id, name = nil)
      @id, @name = id, name
    end

    def ==(other)
      other.instance_of?(self.class) && other.id == id
    end
  end

  class PersonRepo
    class << self
      def object_class
        Person
      end
    end
  end

  attr_reader :repo

  def lazy(repo, id)
    Chassis::Repo::LazyAssociation.new repo, id
  end

  def setup
    @repo = PersonRepo
  end

  def test_inspect_does_not_materialize
    repo.expects(:find).never
    lazy(repo, 1).inspect
  end

  def test_does_not_materialize_for_the_id
    repo.expects(:find).never

    association = lazy repo, 1
    assert_equal 1, association.id
  end

  def test_reports_the_materialized_class
    repo.expects(:find).never

    association = lazy repo, 1
    assert_equal repo.object_class, association.class
  end

  def test_works_with_equality
    repo.expects(:find).never

    a = lazy repo, 1
    b = lazy repo, 1
    c = lazy repo, 2

    assert_equal a, b
    assert_equal b, a

    refute_equal c, a
    refute_equal a, c

    assert a.eql?(b)
    assert b.eql?(a)

    refute b.eql?(c)
    refute c.eql?(b)
  end

  def test_completes_impersonates_the_materialized_class
    repo.expects(:find).never

    association = lazy repo, 1
    assert_instance_of repo.object_class, association
    assert_kind_of repo.object_class, association
    assert association.is_a?(repo.object_class), "is_a? not implemented correctly"
    assert_equal repo.object_class, association.class
  end

  def test_can_be_compared_to_materialized_objects
    repo.expects(:find).never

    person = Person.new 1

    association = lazy repo, person.id

    assert_equal association, person
    assert_equal person, association
  end

  def test_does_not_materialize_twice_when_cached
    person = Person.new 1, 'ahawkins'
    repo.expects(:find).with(person.id).returns(person).once

    association = lazy repo, person.id
    association.materialize

    assert_equal person.name, association.name

    reloaded = Marshal.load(Marshal.dump(association))

    assert_equal person.name, reloaded.name
  end

  def test_calls_to_unknown_methods_materialize_the_object
    person = Person.new 1, 'ahawkins'
    repo.expects(:find).with(person.id).returns(person).once

    association = lazy repo, person.id
    assert_equal person.name, association.name
  end
end
