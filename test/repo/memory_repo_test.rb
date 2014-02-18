require_relative '../test_helper'
require_relative 'repo_tests'

class MemoryRepoTest < MiniTest::Unit::TestCase
  class TestRepo < Chassis::MemoryRepo
    def query_person_named(klass, selector)
      all(klass).select do |person|
        person.name == selector.name
      end
    end

    def graph_query_person_named(klass, selector)
      all(klass).select do |person|
        person.name == selector.name
      end
    end
  end

  include RepoTests

  def setup
    @repo = TestRepo.new
    super
  end
end
