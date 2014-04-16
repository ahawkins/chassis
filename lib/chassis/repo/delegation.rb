module Chassis
  UnknownObjectClassError = Chassis.error do
    "Rename class to end in Repo or define object_class"
  end

  class Repo
    module Delegation
      def all
        backend.all object_class
      end

      def count
        backend.count object_class
      end

      def find(id)
        backend.find object_class, id
      end

      def save(record)
        backend.save(record)
      end

      def delete(record)
        backend.delete record
      end

      def first
        backend.first object_class
      end

      def last
        backend.last object_class
      end

      def query(selector)
        backend.query object_class, selector
      end

      def query!(selector, &block)
        backend.query! object_class, selector, &block
      end

      def sample
        backend.sample object_class
      end

      def empty?
        backend.empty? object_class
      end

      def graph(id)
        backend.graph object_class, id
      end

      def graph_query(selector)
        backend.graph_query object_class, selector
      end

      def lazy(id)
        LazyAssociation.new self, id
      end

      def object_class
        @object_class ||= begin
          fail UnknownObjectClassError unless name
          match = name.match(/^(.+)Repo$/)
          fail UnknownObjectClassError unless match
          match[1].constantize
        end
      end

      def backend
        Repo.default
      end
    end
  end
end
