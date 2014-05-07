module Chassis
  module Rack
    class JsonBodyParser < ::Rack::PostBodyContentTypeParser
      def call(env)
        body = env[POST_BODY].read

        if body.strip.empty?
          @app.call env
        else
          begin
            env[POST_BODY].rewind
            super
          rescue JSON::ParserError => ex
            [400, { 'Content-Type' => 'text/plain' }, [ex.to_s]]
          end
        end
      end
    end
  end
end
