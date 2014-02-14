module ImplementationTests
  Person = Struct.new :name do
    attr_accessor :id
  end

  PersonNamed = Struct.new :name
  PersonFooBarBaz = Class.new

  def test_crud_operations
    person = Person.new 'ahawkins'
    implementation.create person

    assert person.id, "Implementation must set the ID after creating"

    assert_equal 1, implementation.count(Person)

    assert_equal person, implementation.find(Person, person.id)

    assert_equal [person], implementation.all(Person)

    person.name = 'adam'
    implementation.update person
    assert_equal 'adam', implementation.find(Person, person.id).name

    implementation.delete(person)

    assert_equal 0, implementation.count(Person)
  end

  def test_clear_wipes_all_data
    person = Person.new 'ahawkins'
    implementation.create person

    assert_equal 1, implementation.count(Person)

    implementation.clear

    assert_equal 0, implementation.count(Person)
    assert_empty implementation.all(Person)
  end

  def test_raises_error_when_no_reecord_exists
    assert_raises Chassis::RecordNotFoundError do
      implementation.find Person, 1
    end
  end

  def test_first_and_last
    adam = Person.new 'ahawkins'
    peter = Person.new 'pepps'

    implementation.create adam
    implementation.create peter

    assert_equal adam, implementation.first(Person)
    assert_equal peter, implementation.last(Person)
  end

  def test_clear_wipes_data
    adam = Person.new 'ahawkins'
    implementation.create adam

    refute_empty implementation.all(Person)
    assert_equal 1, implementation.count(Person)
    assert implementation.find(Person, adam.id)

    implementation.clear

    assert_empty implementation.all(Person)
    assert_equal 0, implementation.count(Person)
  end

  def test_raises_an_error_when_query_not_implemented
    assert_raises Chassis::QueryNotImplementedError do
      implementation.query Person, PersonFooBarBaz.new
    end
  end

  def test_uses_query_method_to_implement_queries
    adam = Person.new 'ahawkins'
    peter = Person.new 'pepp'

    implementation.create adam
    implementation.create peter

    assert_equal adam, implementation.query(Person, PersonNamed.new('ahawkins'))
  end

  def test_raises_an_error_when_a_graph_query_is_not_implemented
    assert_raises Chassis::GraphQueryNotImplementedError do
      implementation.graph_query Person, PersonFooBarBaz.new
    end
  end

  def test_uses_the_specific_graph_query_method_for_graph_query
    adam = Person.new 'ahawkins'
    peter = Person.new 'pepp'

    implementation.create adam
    implementation.create peter

    assert_equal adam, implementation.graph_query(Person, PersonNamed.new('ahawkins'))
  end
end
