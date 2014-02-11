module Chassis
  UnregisteredImplementationError = Chassis.error do |name|
    "#{name} is not a registered implementation"
  end

  ImplementationMissingError = Chassis.error do |object, method|
    "The #{object.class} does not respond to #{method}"
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

    module Methods
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

      def implementations
        @implementations ||= { }
      end

      def implementation
        @implementation
      end
    end

    module NullImplementationForInstances
      def initialize(*args)
        super
        register :null, NullImplementation.new
        use :null
      end
    end

    def included(base)
      base.include NullImplementationForInstances
    end

    def extended(klass)
      klass.register :null, NullImplementation.new
      klass.use :null
    end

    def initialize(*methods)
      module_eval do
        include Methods
      end

      define_delegate_method :up?

      methods.each do |method|
        define_delegate_method method
      end
    end

    def define_delegate_method(method)
      define_method method do |*args, &block|
        raise ImplementationMissingError.new(implementation, method) unless implementation.respond_to? method
        implementation.send method, *args, &block
      end
    end
  end

  class << self
    def service(*methods)
      Service.new *methods
    end
  end
end
