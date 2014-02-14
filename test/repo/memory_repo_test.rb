require_relative '../test_helper'
require_relative 'repo_tests'

class MemoryRepoTest < MiniTest::Unit::TestCase
  class TestRepo < Chassis::MemoryRepo
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

  include RepoTests

  attr_reader :repo

  def setup
    @repo = TestRepo.new
    super
  end
end
