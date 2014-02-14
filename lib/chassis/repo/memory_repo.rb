module Chassis
  class MemoryRepo < BaseRepo
    class RecordMap
      def initialize
        @hash = { }
      end

      def set(record)
        record_map(record)[record.id] = record
      end

      def get(klass, id)
        class_map(klass).fetch id do
          fail RecordNotFoundError.new(klass, id)
        end
      end

      def delete(record)
        record_map(record).delete record.id
      end

      def all(klass)
        class_map(klass).values
      end

      def clear
        hash.clear
      end

      private
      def hash
        @hash
      end

      def class_map(klass)
        hash[klass] ||= { }
      end

      def record_map(record)
        class_map record.class
      end
    end

    def initialize
      @map = RecordMap.new
    end

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

    private
    def map
      @map
    end

    def next_id
      @counter ||= 0
      @counter = @counter + 1
      @counter
    end
  end
end
