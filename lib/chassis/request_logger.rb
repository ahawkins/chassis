module Chassis
  class RequestLogger
    def initialize(app)
      @app = app
    end

    def call(env)
      began_at = Time.now
      log_request env

      status, header, body = @app.call(env)

      log_response env, status, began_at

      [status, header, body]
    end

    private

    def log_request(env)
      format = %{Processing: %s %s for %s %s\n}
      logger = env['rack.errors']

      request = ::Rack::Request.new(env)

      logger.write(format % [
        request.request_method,
        request.url,
        request.ip,
        env["HTTP_VERSION"]
      ])

      if !request.params.empty?
        logger.write("  Params: %s\n" % [
          request.params.inspect
        ])
      end
    end

    def log_response(env, status, began_at)
      now = Time.now
      format = %{Completed %s in %0.4f ms\n\n}
      logger = env['rack.errors']

      logger.write(format % [
        status,
        (now - began_at).to_f / 1000.0
      ])
    end
  end
end

# Patch Rack::CommonLogger if you want to use this instead
module Rack
  class CommonLogger
    def call(env)
      @app.call env
    end
  end
end
