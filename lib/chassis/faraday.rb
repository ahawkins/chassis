module Chassis
  class HttpRequestFailedError < StandardError
    def initialize(env)
      @env = env
    end

    def to_s
      "#{status} - #{description} : #{method} #{url}"
    end

    def method
      env.fetch(:method).upcase
    end

    def body
      env.fetch :body
    end

    def url
      env.fetch(:url)
    end

    def status
      env.fetch :status
    end

    def description
      ::Rack::Utils::HTTP_STATUS_CODES.fetch status, 'UNKOWN'
    end

    private
    def env
      @env
    end
  end

  # 4xx errors
  HttpClientError = Class.new HttpRequestFailedError
  HttpBadRequestError = Class.new HttpClientError
  HttpUnauthorizedError = Class.new HttpClientError
  HttpPaymentRequiredError = Class.new HttpClientError
  HttpForbiddenError = Class.new HttpClientError
  HttpNotFoundError = Class.new HttpClientError
  HttpMethodNotAllowedError = Class.new HttpClientError
  HttpNotAcceptableError = Class.new HttpClientError
  HttpProxyAuthenticationRequiredError = Class.new HttpClientError
  HttpRequestTimeoutError = Class.new HttpClientError
  HttpConflictError = Class.new HttpClientError
  HttpGoneError = Class.new HttpClientError
  HttpLengthRequiredError = Class.new HttpClientError
  HttpPreconditionFailedError = Class.new HttpClientError
  HttpRequestEntityTooLargeError = Class.new HttpClientError
  HttpRequestUriTooLongError = Class.new HttpClientError
  HttpUnsupportedMediaTypeError = Class.new HttpClientError
  HttpRequestRangeNotSatisfiableError = Class.new HttpClientError
  HttpExpectationFailedError = Class.new HttpClientError
  HttpUnprocessableEntityError = Class.new HttpClientError
  HttpLockedError = Class.new HttpClientError
  HttpFailedDependencyError = Class.new HttpClientError
  HttpUpgradeRequiredError = Class.new HttpClientError

  # 5xx errors
  HttpServerError = Class.new HttpRequestFailedError
  HttpInternalServerError = Class.new HttpServerError
  HttpNotImplementedError = Class.new HttpServerError
  HttpBadGatewayError = Class.new HttpServerError
  HttpServiceUnavailableError = Class.new HttpServerError
  HttpGatewayTimeoutError = Class.new HttpServerError
  HttpVersionNotSupportedError = Class.new HttpServerError
  HttpInsufficientStorageError = Class.new HttpServerError
  HttpNotExtendedError = Class.new HttpServerError

  HTTP_STATUS_CODE_ERROR_MAP = {
    400 => HttpBadRequestError,
    401 => HttpUnauthorizedError,
    402 => HttpPaymentRequiredError,
    403 => HttpForbiddenError,
    404 => HttpNotFoundError,
    405 => HttpMethodNotAllowedError,
    406 => HttpNotAcceptableError,
    407 => HttpProxyAuthenticationRequiredError,
    408 => HttpRequestTimeoutError,
    409 => HttpConflictError,
    410 => HttpGoneError,
    411 => HttpLengthRequiredError,
    412 => HttpPreconditionFailedError,
    413 => HttpRequestEntityTooLargeError,
    414 => HttpRequestUriTooLongError,
    415 => HttpUnsupportedMediaTypeError,
    416 => HttpRequestRangeNotSatisfiableError,
    417 => HttpExpectationFailedError,
    422 => HttpUnprocessableEntityError,
    423 => HttpLockedError,
    424 => HttpFailedDependencyError,
    426 => HttpUpgradeRequiredError,

    # 5xx errors
    500 => HttpInternalServerError,
    501 => HttpNotImplementedError,
    502 => HttpBadGatewayError,
    503 => HttpServiceUnavailableError,
    504 => HttpGatewayTimeoutError,
    505 => HttpVersionNotSupportedError,
    507 => HttpInsufficientStorageError,
    510 => HttpNotExtendedError
  }

  class ServerErrorHandler < ::Faraday::Response::Middleware
    def on_complete(env)
      status = env.fetch :status
      return unless (400..600).include? status
      raise HTTP_STATUS_CODE_ERROR_MAP.fetch(status), env
    end
  end

  class ParseJson < ::Faraday::Response::Middleware
    def on_complete(env)
      return if [204, 304].include? env.fetch(:status)

      content_type = env.fetch(:response_headers).fetch('Content-Type', nil)

      return unless content_type
      return unless content_type =~ /json/

      body = env.body

      return unless body.respond_to? :to_str

      content = body.to_str.strip

      return if content.empty?

      env[:body] = JSON.load content
    end
  end

  class Instrumentation < ::Faraday::Middleware
    include Harness::Instrumentation

    def initialize(app, progname = 'faraday')
      @app, @progname = app, progname
    end

    def call(env)
      time "#{@progname}.#{env.method}" do
        @app.call env
      end
    end
  end

  class EncodeJson < ::Faraday::Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      if env.body
        env[:request_headers]['Content-Type'] = 'application/json'
        env.body = JSON.dump env.body
      end

      @app.call env
    end
  end

  class Logging < ::Faraday::Response::Middleware
    def initialize(app, logger)
      @app, @logger = app, logger
    end

    def call(env)
      dump_request env
      super
    end

    def on_complete(env)
      dump_response env
    end

    private
    def dump_request(env)
      request_line = "> #{env.fetch(:method).to_s.upcase} #{env.fetch(:url)}"
      headers = env.fetch(:request_headers).map do |name, value|
        "> #{name}: #{value}"
      end.join("\n")

      @logger.debug [request_line, headers, env.body].compact.join("\n")
    end

    def dump_response(env)
      status = env.fetch :status
      status_text = ::Rack::Utils::HTTP_STATUS_CODES.fetch status, 'Unknown'
      request_line = "> #{status.to_s.upcase} #{status_text}"
      headers = env.fetch(:response_headers).map do |name, value|
        "> #{name}: #{value}"
      end.join("\n")

      @logger.debug [request_line, headers, env.body].compact.join("\n")
    end
  end

  ::Faraday::Request.register_middleware instrumentation: Instrumentation
  ::Faraday::Request.register_middleware encode_json: EncodeJson

  ::Faraday::Response.register_middleware parse_json: ParseJson
  ::Faraday::Response.register_middleware server_error_handler: ServerErrorHandler
  ::Faraday::Response.register_middleware logging: Logging

  class << self
    def faraday(host, options = {})
      namespace = options.delete :namespace
      logger = options.delete(:logger) || Logger.new.tap { |l| l.progname = 'faraday' }

      Faraday.new host, options do |conn|
        conn.request :instrumentation, namespace
        conn.request :encode_json

        conn.response :parse_json
        conn.response :server_error_handler
        conn.response :logging, logger

        yield conn if block_given?
      end
    end
  end
end
