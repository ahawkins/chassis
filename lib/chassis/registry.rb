module Chassis
  UnregisteredError = Chassis.error do |key|
    "#{key.inspect} is not registered!"
  end

  class Registry
    def initialize
      @map = { }
    end

    def []=(key, value)
      map[key] = value
    end

    def fetch(key)
      map.fetch key do
        fail UnregisteredError, key
      end
    end

    def clear
      map.clear
    end

    private
    def map
      @map
    end
  end
end
