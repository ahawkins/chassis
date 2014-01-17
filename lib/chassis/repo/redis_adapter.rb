module Chassis
  class Repo
    class RedisAdapter < InMemoryAdapter
      class RedisMapper
        attr_reader :klass, :redis

        def initialize(klass, redis)
          @klass, @redis = klass, redis
        end

        def []=(id, obj)
          map = read
          map[id.to_s] = obj

          write map
        end

        def [](id)
          read[id.to_s]
        end

        def values
          read.values
        end

        def delete(id)
          map = read
          map.delete id.to_s
          write map
        end

        def count
          read.count
        end

        private
        def read
          value = redis.get(key)
          value ? Marshal.load(value) : { }
        end

        def write(map)
          redis.set key, Marshal.dump(map)
        end

        def key
          klass.to_s
        end
      end

      def initialize(redis = Redis.new)
        @redis = redis
      end

      def clear
        redis.flushall
      end

      def map_for_class(klass)
        RedisMapper.new klass, redis
      end

      private
      def redis
        @redis
      end
    end
  end
end
