require_relative '../test_helper'
require_relative 'repo_tests'
require 'pstore'

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
    pstore = PStore.new tmp_path.join('repo.pstore')
    @repo = TestRepo.new pstore
    super
  end
end
