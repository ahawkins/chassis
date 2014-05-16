require_relative '../test_helper'

class ExceptionHandlingTest < MiniTest::Unit::TestCase
  DummyError = Class.new StandardError

  class FakeLogger
    def initialize
      @written = [ ]
    end

    def write(*args)
      @written << args.join
    end

    def flush(*args)
      @printed = @written
    end

    def printed
      @printed.join
    end
  end

  def test_reports_errors_as_json
    app = ->(env) { fail "Test Error" }

    middleware = Chassis::Rack::ExceptionHandling.new app

    env = { 'rack.errors' => FakeLogger.new }

    status, headers, body = middleware.call env

    assert_equal 'application/json', headers.fetch('Content-Type')
    refute_empty body
    hash = JSON.load body.each.to_a.join('')

    assert_equal 500, status
  end

  def test_prints_trace_to_error_stream
    app = ->(env) { fail DummyError, "Test Error" }

    middleware = Chassis::Rack::ExceptionHandling.new app

    logger = FakeLogger.new
    env = { 'rack.errors' => logger }

    middleware.call env

    refute_empty logger.printed
    assert_includes logger.printed, DummyError.name, 'Exception class should be printed'
    assert_includes logger.printed, 'Test Error', 'Message should be printed'
  end

  def test_calls_through_to_the_app
    app = ->(env) { [200, { }, ['ok']] }

    middleware = Chassis::Rack::ExceptionHandling.new app

    status, headers, body = middleware.call({ })

    assert_equal 200, status
  end
end
