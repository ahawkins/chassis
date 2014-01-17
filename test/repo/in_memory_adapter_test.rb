require_relative '../test_helper'
require_relative 'adapter_tests'

class InMemoryAdapterTest < MiniTest::Unit::TestCase
  class TestAdapter < Chassis::Repo::InMemoryAdapter
    def query_person_named(klass, selector)
      all(klass).find do |person|
        person.name == selector.name
      end
    end

    def graph_query_person_named(klass, selector)
      all(klass).find do |person|
        person.name == selector.name
      end
    end
  end

  attr_reader :adapter

  def setup
    @adapter = TestAdapter.new
    super
  end
end
