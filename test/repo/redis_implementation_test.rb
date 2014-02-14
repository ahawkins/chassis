require_relative '../test_helper'
require_relative 'implementation_tests'

class RedisImplementationTest < MiniTest::Unit::TestCase
  class TestImplementation < Chassis::Repo::RedisImplementation
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

  attr_reader :implementation

  def setup
    @implementation = TestImplementation.new
    super
  end
end
