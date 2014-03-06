module Chassis
  class BaseRepo
    def create(record)
      record.id ||= next_id
      map.set record
    end

    def update(record)
      map.set record
    end

    def delete(record)
      map.delete record
    end

    def clear
      map.clear
    end

    def all(klass)
      map.all klass
    end

    def find(klass, id)
      map.get klass, id
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

    def count(klass)
      all(klass).count
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

    def initialize_storage

    end

    private
    def map
      @map
    end

    def next_id
      @counter ||= 0
      @counter = @counter + 1
      @counter
    end

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
