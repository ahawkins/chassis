module Chassis
  class Repo
    class MemoryImplementation < BaseImplementation
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

      def map_for_class(klass)
        @map[klass.to_s.to_sym] ||= {}
      end

      def map_for(record)
        map_for_class(record.class)
      end
    end
  end
end
