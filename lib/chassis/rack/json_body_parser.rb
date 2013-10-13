module Chassis
  class MultiJsonBodyParser < Rack::PostBodyContentTypeParser
    def call(env)
      if Rack::Request.new(env).media_type == APPLICATION_JSON && (body = env[POST_BODY].read).length != 0
        env[POST_BODY].rewind # somebody might try to read this stream
        env.update(FORM_HASH => MultiJson.load(body), FORM_INPUT => env[POST_BODY])
      end

      @app.call(env)
    end
  end
end
