module Chassis
  class CircuitPanel
    class << self
      def build(&block)
        raise ArgumentError, "block required" unless block
        Class.new self, &block
      end

      def circuit(name, options = {})
        define_method name do
          Breaker.circuit name, options
        end
      end
    end
  end

  class << self
    def circuit_panel(&block)
      CircuitPanel.build &block
    end
  end
end
