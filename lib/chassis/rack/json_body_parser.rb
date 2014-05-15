module Chassis
  module Rack
    class JsonBodyParser < ::Rack::PostBodyContentTypeParser
      def call(env)
        begin
          if ::Rack::Request.new(env).media_type == APPLICATION_JSON && !(body = env[POST_BODY].read.strip).empty?
            env[POST_BODY].rewind # somebody might try to read this stream
            env.update(FORM_HASH => JSON.parse(body), FORM_INPUT => env[POST_BODY])
          end
          @app.call(env)
        rescue JSON::ParserError => ex
          [400, { 'Content-Type' => 'text/plain' }, [ex.to_s]]
        end
      end
    end
  end
end
