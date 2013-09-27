require 'active_support/concern'

module Chassis
  class Repo
    class RecordNotFound < StandardError
      def initialize(klass, id)
        @klass, @id = klass, id
      end

      def to_s
        "Could not locate #{@klass} with id #{@id}"
      end
    end

    class << self
      def backend
        @backend
      end

      def backend=(backend)
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

      def reset
        backend.reset
      end
    end

    class InMemoryBackend
      def initialize_storage!
        @counter = 0
        @map = {}
      end

      def create(record)
        @counter = @counter + 1
        record.id ||= @counter
        map_for(record)[record.id] = record
      end

      def update(record)
        map_for(record)[record.id] = record
      end

      def delete(record)
        map_for(record).delete record.id
      end

      def count(klass)
        map_for_class(klass).count
      end

      def find(klass, id)
        record = map_for_class(klass)[id]

        raise Repo::RecordNotFound.new(klass, id) unless record

        record
      end

      def clear
        @map.clear
      end
      alias :reset :clear

      def all(klass)
        map_for_class(klass).values
      end

      def first(klass)
        all(klass).first
      end

      def last(klass)
        all(klass).last
      end

      def sample(klass)
        all(klass).sample
      end

      def map_for_class(klass)
        @map[klass.to_s.to_sym] ||= {}
      end

      def map_for(record)
        map_for_class(record.class)
      end
    end

    class NullBackend
      def initialize_storage!
        @counter = 0
      end

      def create(record)
        @counter = @counter + 1
        record.id ||= @counter
      end

      def update(record)

      end

      def delete(record)

      end

      def clear

      end

      def count

      end

      def first

      end

      def all(klass)
        [ ]
      end

      def query(klass, q)

      end

      def reset

      end
    end

    module Delegation
      extend ActiveSupport::Concern

      module ClassMethods
        def save(record)
          Repo.save(record)
        end

        def all
          Repo.all object_class
        end

        def count
          Repo.count object_class
        end

        def find(id)
          Repo.find object_class, id
        end

        def delete(record)
          Repo.delete record
        end

        def first
          Repo.first object_class
        end

        def last
          Repo.last object_class
        end

        def query(selector)
          Repo.query object_class, selector
        end

        def sample
          Repo.sample object_class
        end

        def graph(id)
          Repo.graph object_class, id
        end

        def graph_query(selector)
          Repo.graph_query object_class, selector
        end

        def object_class
          @object_class ||= self.to_s.match(/^(.+)Repo/)[1].constantize
        end
      end
    end
  end
end
