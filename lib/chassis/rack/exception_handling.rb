module Chassis
  module Rack
    class ExceptionHandling
      def initialize(app)
        @app = app
      end

      def call(env)
        begin
          @app.call env
        rescue => ex
          env['rack.errors'].write ex.to_s
          env['rack.errors'].write ex.backtrace.join("\n")
          env['rack.errors'].flush

          hash = { message: ex.to_s }
          [500, {'Content-Type' => 'application/json'}, [JSON.dump(hash)]]
        end
      end
    end
  end
end
