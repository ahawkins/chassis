require_relative 'test_helper'

class RepoTest < MiniTest::Unit::TestCase
  Person = Struct.new :name do
    attr_accessor :id
  end

  attr_reader :repo

  def setup
    @repo = Chassis::Repo.new Chassis::Repo::InMemoryBackend.new
    repo.initialize_storage!
  end

  def test_crud_operations
    person = Person.new 'ahawkins'
    repo.save person
    assert person.id, "Repo must set the ID after creating"

    assert_equal 1, repo.count(Person)

    assert_equal person, repo.find(Person, person.id)

    assert_equal [person], repo.all(Person)

    person.name = 'adam'
    repo.save person
    assert_equal 'adam', repo.find(Person, person.id).name

    repo.delete(person)

    assert_equal 0, repo.count(Person)
  end

  def test_first_and_last
    adam = Person.new 'ahawkins'
    peter = Person.new 'pepps'

    repo.save adam
    repo.save peter

    assert_equal adam, repo.first(Person)
    assert_equal peter, repo.last(Person)
  end

  def test_clear_wipes_data
    adam = Person.new 'ahawkins'
    repo.save adam

    refute_empty repo.all(Person)
    assert_equal 1, repo.count(Person)
    assert repo.find(Person, adam.id)

    repo.clear

    assert_empty repo.all(Person)
    assert_equal 0, repo.count(Person)
  end
end
