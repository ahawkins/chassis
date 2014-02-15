require_relative '../test_helper'
require_relative 'repo_tests'
require 'pstore'
require 'tempfile'

class PStoreRepoTest < MiniTest::Unit::TestCase
  class TestRepo < Chassis::PStoreRepo
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
    tempfile = Tempfile.new 'pstore.test'
    @repo = TestRepo.new PStore.new(tempfile.path)
    super
  end
end
