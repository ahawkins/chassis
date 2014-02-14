module Chassis
  class Repo
    class MemoryImplementation
      def initialize
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

        raise RecordNotFoundError.new(klass, id) unless record

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

      def map_for_class(klass)
        @map[klass.to_s.to_sym] ||= {}
      end

      def map_for(record)
        map_for_class(record.class)
      end
    end
  end
end
