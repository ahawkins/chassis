require "chassis/version"

require 'multi_json'
require 'sinatra'
require 'manifold'
require 'rack/contrib/bounce_favicon'
require 'rack/contrib/post_body_content_type_parser'

require 'harness'

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

    class StatusCheck
      def initialize(app)
        @app = app
      end

      def call(env)
        if env.fetch('PATH_INFO') == '/status'
          [200, { 'Content-Type' => 'text/plain' }, ['Goliath Online!']]
        else
          @app.call env
        end
      end
    end

    class ExceptionHandling
      def initialize(app, include_trace = true)
        @app, @include_trace = app, include_trace
      end

      def call(env)
        begin
          @app.call env
        rescue => ex
          hash = { message: ex.to_s }
          hash[:backtrace] = ex.backtrace if @include_trace

          [500, {'Content-Type' => 'application/json'}, [MultiJson.dump(hash)]]
        end
      end
    end

    configure do
      # Don't capture any errors. Throw them up the stack
      set :raise_errors, true

      # Disable internal middleware for presenting errors
      # as useful HTML pages
      set :show_exceptions, false
    end

    use StatusCheck
    use Rack::BounceFavicon
    use Manifold::Middleware
    use Rack::Runtime
    use Harness::RackInstrumenter
    use Rack::Deflater
    use MultiJsonBodyParser
  end
end
