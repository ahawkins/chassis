require_relative '../test_helper'
require_relative 'implementation_tests'

class InMemoryImplementationTest < MiniTest::Unit::TestCase
  class TestImplementation < Chassis::Repo::MemoryImplementation
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

  include ImplementationTests

  attr_reader :implementation

  def setup
    @implementation = TestImplementation.new
    super
  end
end
