module RepoTests
  Person = Struct.new :name do
    attr_accessor :id
  end

  PersonNamed = Struct.new :name
  PersonFooBarBaz = Class.new

  def repo
    fail "test class must assign @repo" unless @repo
    @repo
  end

  def setup
    repo.clear
    repo.initialize_storage
  end

  def test_crud_operations
    assert_equal 0, repo.count(Person), "Precondition: there should be no records"

    person = Person.new 'ahawkins'
    repo.create person

    assert person.id, "repo must set the ID after creating"

    assert_equal 1, repo.count(Person)

    assert_equal person, repo.find(Person, person.id)

    assert_equal [person], repo.all(Person)

    person.name = 'adam'
    repo.update person
    assert_equal 'adam', repo.find(Person, person.id).name

    repo.delete(person)

    assert_equal 0, repo.count(Person)
  end

  def test_raises_error_when_no_reecord_exists
    assert_equal 0, repo.count(Person)

    assert_raises Chassis::RecordNotFoundError do
      repo.find Person, 1
    end
  end

  def test_first_and_last
    assert_equal 0, repo.count(Person), "Precondition: there should be no records"

    adam = Person.new 'ahawkins'
    peter = Person.new 'pepps'

    repo.create adam
    repo.create peter

    assert_equal adam, repo.first(Person)
    assert_equal peter, repo.last(Person)
  end

  def test_clear_wipes_data
    assert_equal 0, repo.count(Person), "Precondition: there should be no records"

    adam = Person.new 'ahawkins'
    repo.create adam

    refute_empty repo.all(Person)
    assert_equal 1, repo.count(Person)
    assert repo.find(Person, adam.id)

    repo.clear

    assert_empty repo.all(Person)
    assert_equal 0, repo.count(Person)
  end

  def test_raises_an_error_when_query_not_implemented
    assert_raises Chassis::QueryNotImplementedError do
      repo.query Person, PersonFooBarBaz.new
    end
  end

  def test_uses_query_method_to_implement_queries
    assert_equal 0, repo.count(Person), "Precondition: there should be no records"

    adam = Person.new 'ahawkins'
    peter = Person.new 'pepp'

    repo.create adam
    repo.create peter

    assert_equal 2, repo.count(Person)

    query = repo.query(Person, PersonNamed.new('ahawkins'))
    refute_empty query
    assert_equal adam, query.first
  end

  def test_raises_an_error_when_a_graph_query_is_not_implemented
    assert_raises Chassis::GraphQueryNotImplementedError do
      repo.graph_query Person, PersonFooBarBaz.new
    end
  end

  def test_uses_the_specific_graph_query_method_for_graph_query
    assert_equal 0, repo.count(Person), "Precondition: there should be no records"

    adam = Person.new 'ahawkins'
    peter = Person.new 'pepp'

    repo.create adam
    repo.create peter

    query = repo.query(Person, PersonNamed.new('ahawkins'))
    refute_empty query
    assert_equal adam, query.first
  end
end
