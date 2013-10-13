module Chassis
  class Repo
    class RecordNotFoundError < StandardError
      def initialize(klass, id)
        @klass, @id = klass, id
      end

      def to_s
        "Could not locate #{@klass} with id #{@id}"
      end
    end

    class QueryNotImplementedError < StandardError
      def initialize(selector)
        @selector = selector
      end

      def to_s
        "Adapter does not support #{@selector.class}!"
      end
    end

    class GraphQueryNotImplementedError < StandardError
      def initialize(selector)
        @selector = selector
      end

      def to_s
        "Adapter does not know how to graph #{@selector.class}!"
      end
    end

    include Singleton

    def self.backend
      @backend
    end

    def self.backend=(backend)
      @backend = backend
    end

    def initialize(backend = Repo.backend)
      @backend = backend
    end

    def initialize_storage!
      backend.initialize_storage!
    end

    def clear
      backend.clear
    end

    def count(klass)
      backend.count klass
    end

    def find(klass, id)
      raise ArgumentError, "id cannot be nil!" if id.nil?
      backend.find klass, id
    end

    def save(record)
      if record.id
        backend.update record
      else
        backend.create record
      end
    end

    def delete(record)
      backend.delete record
    end

    def first(klass)
      backend.first klass
    end

    def last(klass)
      backend.last klass
    end

    def all(klass)
      backend.all klass
    end

    def query(klass, selector)
      backend.query klass, selector
    end

    def graph(klass, id)
      backend.graph klass, id
    end

    def graph_query(klass, selector)
      backend.graph_query klass, selector
    end

    def sample(klass)
      backend.sample klass
    end
  end
end

require_relative 'repo/in_memory_adapter'
require_relative 'repo/null_adapter'
require_relative 'repo/delegation'
