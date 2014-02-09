require_relative "test_helper"

class FaradayTest < MiniTest::Unit::TestCase
  def setup
    Harness.config.queue = Harness::SyncQueue.new
    Harness.config.collector = Harness::FakeCollector.new
  end

  def stats
    Harness.config.collector
  end

  def build(url = nil, options = {}, &block)
    Faraday.new url, options, &block
  end

  def test_instruments_all_requests
    faraday = build do |conn|
      conn.request :instrumentation

      conn.adapter :test do |stub|
        stub.get 'test' do
          [200, {'Content-Type' => 'application/json'}, JSON.dump(foo: 'bar')]
        end
      end
    end

    faraday.get 'test'

    refute_empty stats.timers
    timer = stats.timers.first

    assert_equal 'faraday.get', timer.name
  end

  def test_instrumentation_namespace_can_be_customized
    faraday = build 'http://example.com' do |conn|
      conn.request :instrumentation, 'http'

      conn.adapter :test do |stub|
        stub.get 'test' do
          [200, {'Content-Type' => 'application/json'}, JSON.dump(foo: 'bar')]
        end
      end
    end

    faraday.get 'test'

    refute_empty stats.timers
    timer = stats.timers.first

    assert_equal 'http.get', timer.name
  end

  def test_sends_requests_in_json
    faraday = build do |conn|
      conn.request :encode_json

      conn.adapter :test do |stub|
        stub.post 'test' do |env|
          json = JSON.load env.fetch(:body)
          [200, {'Content-Type' => 'text/plain'}, json.fetch('foo')]
        end
      end
    end

    response = faraday.post 'test', foo: 'bar'

    assert_equal 'bar', response.body
  end

  def test_parses_json_bodies
    faraday = build do |conn|
      conn.request :encode_json
      conn.response :parse_json

      conn.adapter :test do |stub|
        stub.post 'test' do |env|
          [ 200, 
            {'Requested-Type' => env.fetch(:request_headers).fetch('Content-Type')},
            env.fetch(:body)
          ]
        end
      end
    end

    response = faraday.post 'test', foo: 'bar'

    assert_equal(JSON.dump({ 'foo' => 'bar' }), response.body)
    assert_equal 'application/json', response.headers.fetch('Requested-Type')
  end

  def test_does_not_parse_nil_bodies
    faraday = build do |conn|
      conn.response :parse_json

      conn.adapter :test do |stub|
        stub.get 'test' do
          [200, {'Content-Type' => 'application/json'}, nil]
        end
      end
    end

    response = faraday.get 'test'

    assert_nil response[:body]
  end

  def test_does_not_parse_empty_bodies
    faraday = build do |conn|
      conn.response :parse_json

      conn.adapter :test do |stub|
        stub.get 'test' do
          [200, {'Content-Type' => 'application/json'}, '']
        end
      end
    end

    response = faraday.get 'test'

    assert_nil response[:body]
  end

  def test_does_not_parse_empty_strings
    faraday = build do |conn|
      conn.response :parse_json

      conn.adapter :test do |stub|
        stub.get 'test' do
          [200, {'Content-Type' => 'application/json'}, '      ']
        end
      end
    end

    response = faraday.get 'test'

    assert_nil response[:body]
  end

  def test_does_not_parse_204s
    faraday = build do |conn|
      conn.response :parse_json

      conn.adapter :test do |stub|
        stub.get 'test' do
          [204, {'Content-Type' => 'application/json'}, '']
        end
      end
    end

    response = faraday.get 'test'

    assert_nil response[:body]
  end

  def test_does_not_parse_304s
    faraday = build do |conn|
      conn.response :parse_json

      conn.adapter :test do |stub|
        stub.get 'test' do
          [304, {'Content-Type' => 'application/json'}, '']
        end
      end
    end

    response = faraday.get 'test'

    assert_nil response[:body]
  end

  def test_logs_requests
    stream = StringIO.new
    logger = Logger.new stream
    logger.level = :debug

    faraday = build 'http://example.com' do |conn|
      conn.response :logging, logger

      conn.adapter :test do |stub|
        stub.get 'test' do
          [200, {}, 'dead']
        end
      end
    end

    faraday.get 'test', { foo: 'bar' }, { 'This-Header' => 'has_a_value' }

    stream.rewind ; content = stream.read

    assert_includes content, 'http://example.com/test'
    assert_includes content, 'This-Header'
    assert_includes content, 'has_a_value'
    assert_includes content, 'foo'
    assert_includes content, 'bar'
  end

  def test_logs_responses
    stream = StringIO.new
    logger = Logger.new stream
    logger.level = :debug

    faraday = build 'http://example.com' do |conn|
      conn.response :logging, logger

      conn.adapter :test do |stub|
        stub.get 'test' do
          [200, {'This-Header' => 'has_a_value'}, 'the_body']
        end
      end
    end

    faraday.get 'test'

    stream.rewind ; content = stream.read

    assert_includes content, '200'
    assert_includes content, 'This-Header'
    assert_includes content, 'has_a_value'
    assert_includes content, 'the_body'
  end

  def test_raises_a_bad_request_error
    faraday = build do |conn|
      conn.response :server_error_handler

      conn.adapter :test do |stub|
        stub.get 'test' do
          [400, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpBadRequestError do
      response = faraday.get 'test'
    end
  end

  def test_raises_an_unauthorized_error
    faraday = build do |conn|
      conn.response :server_error_handler

      conn.adapter :test do |stub|
        stub.get 'test' do
          [401, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpUnauthorizedError do
      response = faraday.get 'test'
    end
  end

  def test_raises_a_payment_required_error
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [402, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpPaymentRequiredError do
      response = faraday.get 'test'
    end
  end

  def test_raises_a_forbidden_error
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [403, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpForbiddenError do
      response = faraday.get 'test'
    end
  end

  def test_raises_a_not_found_error
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [404, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpNotFoundError do
      response = faraday.get 'test'
    end
  end

  def test_raises_a_method_not_allowed_error
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [405, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpMethodNotAllowedError do
      response = faraday.get 'test'
    end
  end

  def test_raises_an_unacceptable_error
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [406, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpNotAcceptableError do
      response = faraday.get 'test'
    end
  end

  def test_raises_a_proxy_auth_error
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [407, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpProxyAuthenticationRequiredError do
      response = faraday.get 'test'
    end
  end

  def test_raises_a_timeout_error
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [408, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpRequestTimeoutError do
      response = faraday.get 'test'
    end
  end

  def test_raises_a_conflict_error
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [409, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpConflictError do
      response = faraday.get 'test'
    end
  end

  def test_raises_a_gone_error
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [410, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpGoneError do
      response = faraday.get 'test'
    end
  end

  def test_raises_length_required
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [411, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpLengthRequiredError do
      response = faraday.get 'test'
    end
  end

  def test_raises_precondition_failed
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [412, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpPreconditionFailedError do
      response = faraday.get 'test'
    end
  end

  def test_raises_request_entity_too_large
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [413, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpRequestEntityTooLargeError do
      response = faraday.get 'test'
    end
  end

  def test_raises_request_uri_too_long
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [414, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpRequestUriTooLongError do
      response = faraday.get 'test'
    end
  end

  def test_raises_unsupported_media_type
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [415, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpUnsupportedMediaTypeError do
      response = faraday.get 'test'
    end
  end

  def test_raises_range_not_satisfiable
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [416, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpRequestRangeNotSatisfiableError do
      response = faraday.get 'test'
    end
  end

  def test_raises_expectation_failed
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [417, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpExpectationFailedError do
      response = faraday.get 'test'
    end
  end

  def test_raises_unprocessable_entity
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [422, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpUnprocessableEntityError do
      response = faraday.get 'test'
    end
  end

  def test_raises_locked_error
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [423, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpLockedError do
      response = faraday.get 'test'
    end
  end

  def test_raises_failed_dependency_error
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [424, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpFailedDependencyError do
      response = faraday.get 'test'
    end
  end

  def test_raises_upgrade_require_error
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [426, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpUpgradeRequiredError do
      response = faraday.get 'test'
    end
  end

  def test_raises_internal_server_error
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [500, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpInternalServerError do
      response = faraday.get 'test'
    end
  end

  def test_raises_not_implemented_error
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [501, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpNotImplementedError do
      response = faraday.get 'test'
    end
  end

  def test_raises_bad_gateway_error
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [502, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpBadGatewayError do
      response = faraday.get 'test'
    end
  end

  def test_raises_service_unavailable
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [503, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpServiceUnavailableError do
      response = faraday.get 'test'
    end
  end

  def test_raises_gateway_timeout
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [504, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpGatewayTimeoutError do
      response = faraday.get 'test'
    end
  end

  def test_raises_http_version_not_supported_error
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [505, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpVersionNotSupportedError do
      response = faraday.get 'test'
    end
  end

  def test_raises_insuffcient_storage
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [507, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpInsufficientStorageError do
      response = faraday.get 'test'
    end
  end

  def test_raises_not_extended_error
    faraday = build do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test' do
          [510, {}, 'dead']
        end
      end
    end

    assert_raises Chassis::HttpNotExtendedError do
      response = faraday.get 'test'
    end
  end

  def test_server_errors_contain_useful_information
    faraday = build 'http://example.com' do |conn|
      conn.response :server_error_handler
      conn.adapter :test do |stub|
        stub.get 'test.error' do
          [500, {}, 'dead']
        end
      end
    end

    begin
      faraday.get 'test.error'
    rescue => ex
      exception = ex
    end

    assert exception
    msg = exception.to_s
    assert_includes msg, "http://example.com/test.error"
  end

  def test_has_factory_for_faraday_connections
    faraday = Chassis.faraday 'http://example.com'

    stack = faraday.builder.handlers

    assert_includes stack, Chassis::Instrumentation
    assert_includes stack, Chassis::EncodeJson
    assert_includes stack, Chassis::ParseJson
    assert_includes stack, Chassis::ServerErrorHandler
    assert_includes stack, Chassis::Logging
  end

  def test_factory_can_change_the_namespace
    faraday = Chassis.faraday 'http://example.com', namespace: 'test' do |conn|
      conn.adapter :test do |stub|
        stub.get 'test' do
          [200, {'Content-Type' => 'application/json'}, JSON.dump(foo: 'bar')]
        end
      end
    end

    faraday.get 'test'

    refute_empty stats.timers
    timer = stats.timers.first

    assert_equal 'test.get', timer.name
  end

  def test_factory_can_change_the_logger
    stream = StringIO.new
    logger = Logger.new stream
    logger.level = :debug

    faraday = Chassis.faraday 'http://example.com', logger: logger do |conn|
      conn.adapter :test do |stub|
        stub.get 'test' do
          [200, {}, 'dead']
        end
      end
    end

    faraday.get 'test', { foo: 'bar' }, { 'This-Header' => 'has_a_value' }

    stream.rewind ; content = stream.read

    assert_includes content, 'http://example.com/test'
    assert_includes content, 'This-Header'
    assert_includes content, 'has_a_value'
    assert_includes content, 'foo'
    assert_includes content, 'bar'
  end
end
