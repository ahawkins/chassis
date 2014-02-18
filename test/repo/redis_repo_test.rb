require_relative '../test_helper'
require_relative 'repo_tests'
require 'redis'

class RedisRepoTest < MiniTest::Unit::TestCase
  class TestRepo < Chassis::RedisRepo
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
    @repo = TestRepo.new Redis.new
    super
  end
end
