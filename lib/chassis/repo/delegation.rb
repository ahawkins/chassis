module Chassis
  class Repo
    module Delegation
      def all
        Repo.instance.all object_class
      end

      def count
        Repo.instance.count object_class
      end

      def find(id)
        Repo.instance.find object_class, id
      end

      def save(record)
        Repo.instance.save(record)
      end

      def delete(record)
        Repo.instance.delete record
      end

      def first
        Repo.instance.first object_class
      end

      def last
        Repo.instance.last object_class
      end

      def query(selector)
        Repo.instance.query object_class, selector
      end

      def sample
        Repo.instance.sample object_class
      end

      def graph(id)
        Repo.instance.graph object_class, id
      end

      def graph_query(selector)
        Repo.instance.graph_query object_class, selector
      end

      def object_class
        @object_class ||= self.to_s.match(/^(.+)Repo/)[1].constantize
      end
    end
  end
end
