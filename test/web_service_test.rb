require_relative 'test_helper'

class WebServiceTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  attr_reader :app

  def setup
    @app = Chassis::WebService
  end

  def test_form_errors_return_400
    @app = Class.new Chassis::WebService do
      get '/' do
        raise Chassis::UnknownFormFieldError, :test
      end
    end

    get '/'

    assert_equal 400, last_response.status
    assert_json last_response
    assert_error_message last_response
  end

  def test_repo_record_not_found_returns_404
    @app = Class.new Chassis::WebService do
      get '/' do
        raise Chassis::RecordNotFoundError.new(Object, 'some-id')
      end
    end

    get '/'

    assert_equal 404, last_response.status
    assert_json last_response
    assert_error_message last_response
  end

  def test_raise_an_error_when_required_param_is_not_given
    @app = Class.new Chassis::WebService do
      get '/' do
        extract! :post
      end
    end

    get '/'

    assert_equal 400, last_response.status
    assert_json last_response
    assert_error_message last_response
  end

  def test_parses_json_requests
    assert_middleware app.middleware, Rack::PostBodyContentTypeParser
  end

  def test_blocks_robots
    assert_middleware app.middleware, Chassis::Rack::NoRobots
  end

  def test_bounces_bad_requests
    assert_middleware app.middleware, Chassis::Rack::Bouncer
  end

  def test_blocks_noob_favicon
    assert_middleware app.middleware, Rack::BounceFavicon
  end

  def test_uses_gzip
    assert_middleware app.middleware, Rack::Deflater
  end

  def test_can_enable_cors
    @app = Class.new Chassis::WebService do
      enable :cors 

      get '/' do
        'hi'
      end
    end

    options '/'

    assert_equal '*', last_response.headers.fetch('Access-Control-Allow-Origin')
  end

  private
  def assert_json(response)
    assert_includes response.content_type, 'application/json'
  end

  def assert_error_message(response)
    json = JSON.load(response.body)
    assert json.fetch('error').fetch('message')
  end

  def assert_middleware(stack, klass)
    klasses = stack.map { |m| m.first }
    assert_includes klasses, klass, "#{klass} should be in the middleware stack"
  end

  def refute_middleware(stack, klass)
    klasses = stack.map { |m| m.first }
    refute_includes klasses, klass, "#{klass} should not be in the middleware stack"
  end
end
