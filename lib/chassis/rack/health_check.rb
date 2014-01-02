module Chassis
  HealthCheckError = Class.new RuntimeError

  module Rack
    class Ping
      def initialize(app, &block)
        @app, @block = app, block
      end

      def call(env)
        if '/ping' == env.fetch('PATH_INFO')
          if @block
            begin
              result = @block.call(::Rack::Request.new(env))
              raise "health check did not return correctly" unless result
            rescue => boom
              raise HealthCheckError, boom.to_s
            end
          end

          [200, {'Content-Type' => 'text/plain'}, ['pong']]
        else
          @app.call env
        end
      end
    end

    class HealthCheck
      def initialize(app)
        @app = app
      end

      def call(env)
        begin
          @app.call env
        rescue HealthCheckError => ex
          env['rack.errors'].write ex.to_s
          env['rack.errors'].write ex.backtrace.join("\n")
          env['rack.errors'].flush
          exit!
        end
      end
    end
  end
end
