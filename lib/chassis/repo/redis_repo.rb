module Chassis
  class RedisRepo < Chassis::BaseRepo
    class RedisMap
      def initialize(redis)
        @redis = redis
      end

      def clear
        redis.del key
      end

      def all(klass)
        read.all klass
      end

      def get(klass, id)
        read.get klass, id
      end

      def set(record)
        map = read
        map.set record
        write map
      end

      def delete(record)
        map = read
        map.delete record
        write map
      end

      private
      def key
        'repo'
      end

      def redis
        @redis
      end

      def read
        value = redis.get key
        value ? Marshal.load(value) : Repo::RecordMap.new
      end

      def write(map)
        redis.set key, Marshal.dump(map)
      end
    end

    def initialize(redis)
      @map = RedisMap.new redis
    end
  end
end
