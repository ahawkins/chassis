require 'rack/runtime'

module Chassis
  module Rack
    class Instrumentation
      def initialize(app, namespace = nil)
        stack = ::Rack::Builder.new
        stack.use ::Rack::Runtime
        stack.use ::Harness::RackInstrumenter, namespace
        stack.run app

        @app = stack.to_app
      end

      def call(env)
        @app.call env
      end
    end
  end
end
