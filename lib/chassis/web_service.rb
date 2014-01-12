require 'sinatra'
require 'sinatra/json'
require 'rack/contrib/bounce_favicon'
require 'rack/deflater'

module Chassis
  class WebService < Sinatra::Base
    class ParameterMissingError < StandardError
      def initialize(key)
        @key = key
      end

      def to_s
        %Q{Request did not provide "#{@key}"}
      end
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

    error Chassis::Form::UnknownFieldError do
      halt_json_error 400
    end

    error Chassis::Repo::RecordNotFoundError do
      halt_json_error 404
    end

    use Rack::Bouncer
    use ::Rack::BounceFavicon
    use ::Rack::Deflater
    use ::Rack::PostBodyContentTypeParser
  end
end
