module Chassis
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

      def object_class
        @object_class ||= self.to_s.match(/^(.+)Repo/)[1].constantize
      end

      def backend
        Repo.instance
      end
    end
  end
end
