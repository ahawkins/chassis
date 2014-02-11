module Chassis
  class UnregisteredImplementationError < StandardError
    def initialize(name)
      super "#{name} is not a registered implementation"
    end
  end

  class NotImplementedError < StandardError
    def initialize(object, method)
      super "The #{object.class} does not respond to #{method}"
    end
  end

  class Service < Module
    class NullImplementation
      def up?
        true
      end

      def respond_to?(*args)
        true
      end

      def method_missing(name, *args, &block)
        args
      end
    end

    def initialize(*methods)
      methods.each do |method|
        define__method method do |*args, &block|
          raise NotImplementedError.new(implementation, method) unless implementation.respond_to? method
          implementation.send method, *args, &block
        end
      end
    end

    def register(name, implementation)
      implementations[name] = implementation
    end

    def use(name)
      @implementation = implementations.fetch name do
        raise UnregisteredImplementationError, name
      end
    end

    def down?
      !up?
    end

    private
    def implementations
      @implementations ||= {}
    end

    def implementation
      @implementation
    end
  end

  class << self
    def service(*methods)
      Service.new *methods
    end
  end
end
