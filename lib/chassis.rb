require "chassis/version"

require 'multi_json'
require 'sinatra'
require 'rack/contrib/bounce_favicon'
require 'rack/contrib/post_body_content_type_parser'

module Chassis
  class WebApp < Sinatra::Base
    class MultiJsonBodyParser < Rack::PostBodyContentTypeParser
      def call(env)
        if Rack::Request.new(env).media_type == APPLICATION_JSON && (body = env[POST_BODY].read).length != 0
          env[POST_BODY].rewind # somebody might try to read this stream
          env.update(FORM_HASH => MultiJson.load(body), FORM_INPUT => env[POST_BODY])
        end

        @app.call(env)
      end
    end

    configure do
      # Don't log them. We'll do that ourself
      set :dump_errors, false

      # Don't capture any errors. Throw them up the stack
      set :raise_errors, true

      # Disable internal middleware for presenting errors
      # as useful HTML pages
      set :show_exceptions, false
    end

    use Rack::BounceFavicon
    use MultiJsonBodyParser
  end
end
