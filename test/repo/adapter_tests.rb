module AdapterTests
  Person = Struct.new :name do
    attr_accessor :id
  end

  PersonNamed = Struct.new :name
  PersonFooBarBaz = Class.new

  def setup
    adapter.initialize_storage!
  end

  def test_crud_operations
    person = Person.new 'ahawkins'
    adapter.create person

    assert person.id, "Adapter must set the ID after creating"

    assert_equal 1, adapter.count(Person)

    assert_equal person, adapter.find(Person, person.id)

    assert_equal [person], adapter.all(Person)

    person.name = 'adam'
    adapter.update person
    assert_equal 'adam', adapter.find(Person, person.id).name

    adapter.delete(person)

    assert_equal 0, adapter.count(Person)
  end

  def test_clear_wipes_all_data
    person = Person.new 'ahawkins'
    adapter.create person

    assert_equal 1, adapter.count(Person)

    adapter.clear

    assert_equal 0, adapter.count(Person)
    assert_empty adapter.all(Person)
  end

  def test_raises_error_when_no_reecord_exists
    assert_raises Chassis::Repo::RecordNotFoundError do
      adapter.find Person, 1
    end
  end

  def test_first_and_last
    adam = Person.new 'ahawkins'
    peter = Person.new 'pepps'

    adapter.create adam
    adapter.create peter

    assert_equal adam, adapter.first(Person)
    assert_equal peter, adapter.last(Person)
  end

  def test_clear_wipes_data
    adam = Person.new 'ahawkins'
    adapter.create adam

    refute_empty adapter.all(Person)
    assert_equal 1, adapter.count(Person)
    assert adapter.find(Person, adam.id)

    adapter.clear

    assert_empty adapter.all(Person)
    assert_equal 0, adapter.count(Person)
  end

  def test_raises_an_error_when_query_not_implemented
    assert_raises Chassis::Repo::QueryNotImplementedError do
      adapter.query Person, PersonFooBarBaz.new
    end
  end

  def test_uses_query_method_to_implement_queries
    adam = Person.new 'ahawkins'
    peter = Person.new 'pepp'

    adapter.create adam
    adapter.create peter

    assert_equal adam, adapter.query(Person, PersonNamed.new('ahawkins'))
  end

  def test_raises_an_error_when_a_graph_query_is_not_implemented
    assert_raises Chassis::Repo::GraphQueryNotImplementedError do
      adapter.graph_query Person, PersonFooBarBaz.new
    end
  end

  def test_uses_the_specific_graph_query_method_for_graph_query
    adam = Person.new 'ahawkins'
    peter = Person.new 'pepp'

    adapter.create adam
    adapter.create peter

    assert_equal adam, adapter.graph_query(Person, PersonNamed.new('ahawkins'))
  end
end
