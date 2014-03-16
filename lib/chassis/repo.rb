module Chassis
  RecordNotFoundError = Chassis.error do |klass, id|
    "Could not locate #{klass} with id #{id}"
  end

  QueryNotImplementedError = Chassis.error do |selector|
    "Adapter does not support #{selector.class}!"
  end

  GraphQueryNotImplementedError = Chassis.error do |selector|
    "Adapter does not know how to graph #{selector.class}!"
  end

  NoQueryResultError = Chassis.error do |selector|
    "Query #{selector.class} must return results!"
  end

  class Repo
    include Chassis.strategy(*[
      :all, :find, :create, :update, :delete,
      :first, :last, :query, :graph_query,
      :sample, :empty?, :count, :clear,
      :initialize_storage
    ])

    class << self
      def default
        @default ||= new
      end
    end

    def find(klass, id)
      raise ArgumentError, "id cannot be nil!" if id.nil?
      super
    end

    def save(record)
      if record.id
        update record
      else
        create record
      end
    end

    def query!(klass, selector)
      result = query klass, selector
      no_results = result.respond_to?(:empty?) ? result.empty? : result.nil?

      if no_results && block_given?
        yield klass, selector
      elsif no_results
        fail NoQueryResultError, selector
      end

      result
    end
  end

  class << self
    def repo
      Repo.default
    end
  end
end

require_relative 'repo/delegation'
require_relative 'repo/lazy_association'
require_relative 'repo/record_map'
require_relative 'repo/base_repo'
require_relative 'repo/null_repo'
require_relative 'repo/memory_repo'
require_relative 'repo/redis_repo'
require_relative 'repo/pstore_repo'
