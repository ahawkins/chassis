module Chassis
  class Repo
    class BaseImplementation
      def first(klass)
        all(klass).first
      end

      def last(klass)
        all(klass).last
      end

      def sample(klass)
        all(klass).sample
      end

      def empty?(klass)
        all(klass).empty?
      end

      def query(klass, selector)
        if query_implemented? klass, selector
          send query_method(klass, selector), klass, selector
        else
          raise QueryNotImplementedError, selector
        end
      end

      def graph_query(klass, selector)
        if graph_query_implemented? klass, selector
          send graph_query_method(klass, selector), klass, selector
        else
          raise GraphQueryNotImplementedError, selector
        end
      end

      private
      def query_method(klass, selector)
        "query_#{selector.class.name.demodulize.underscore}"
      end

      def query_implemented?(klass, selector)
        respond_to? query_method(klass, selector)
      end

      def graph_query_method(klass, selector)
        "graph_query_#{selector.class.name.demodulize.underscore}"
      end

      def graph_query_implemented?(klass, selector)
        respond_to? graph_query_method(klass, selector)
      end
    end
  end
end
