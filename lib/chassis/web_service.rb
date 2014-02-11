require 'sinatra'
require 'sinatra/json'
require 'rack/contrib/bounce_favicon'
require 'rack/deflater'

module Chassis
  class WebService < Sinatra::Base
    ParameterMissingError = Chassis.error do |key|
      %Q{Request did not provide "#{@key}"}
    end

    helpers do
      def extract!(key)
        value = params.fetch(key.to_s) do
          raise ParameterMissingError, key
        end

        raise ParameterMissingError, key unless value.is_a?(Hash)

        value
      end

      def halt_json_error(code, errors = {})
        json_error env.fetch('sinatra.error'), code, errors
      end

      def json_error(ex, code, errors = {})
        halt code, { 'Content-Type' => 'application/json' }, JSON.dump({
          error: { message: ex.message }
        }.merge(errors))
      end
    end

    error ParameterMissingError do
      halt_json_error 400
    end

    error Chassis::UnknownFormFieldError do
      halt_json_error 400
    end

    error Chassis::RecordNotFoundError do
      halt_json_error 404
    end

    use Rack::NoRobots
    use Rack::Bouncer
    use ::Rack::BounceFavicon
    use ::Rack::Deflater
    use ::Rack::PostBodyContentTypeParser

    set :cors, false

    class << self
      def setup_default_middleware(builder)
        super
        builder.use Manifold::Middleware if settings.cors?
      end
    end
  end
end
