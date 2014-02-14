module Chassis
  class Repo
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
  end
end
