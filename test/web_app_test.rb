require_relative 'test_helper'

class WebAppTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  TestError = Class.new StandardError

  attr_reader :app

  def test_has_a_status_route
    @app = Class.new(Chassis::WebApp)
    get '/status'
    assert_equal 200, last_response.status
    assert_equal 'text/plain', last_response.headers.fetch('Content-Type')
  end

  def test_measures_runtime
    @app = Class.new(Chassis::WebApp) do
      get '/timing' do
        'hi'
      end
    end

    get '/timing'
    assert_equal 200, last_response.status
    assert last_response.headers.key?('X-Runtime')
  end

  def test_404s_on_favicon_requests
    @app = Class.new(Chassis::WebApp)
    get '/favicon.ico'
    assert_equal 404, last_response.status
  end

  def test_parses_json_bodies
    @app = Class.new(Chassis::WebApp) do
      post '/foo' do
        status 200
        MultiJson.dump params.fetch('test')
      end
    end

    post '/foo', MultiJson.dump(test: { these: :params }), 'CONTENT_TYPE' => 'application/json'
    assert_equal MultiJson.dump(these: :params), last_response.body
  end

  def test_raises_errors
    @app = Class.new(Chassis::WebApp) do
      get '/foo' do
        raise TestError
      end
    end

    assert_raises TestError do
      get '/foo'
    end
  end

  def test_cors_support_is_on_by_default
    @app = Class.new(Chassis::WebApp) do
      get '/foo' do
        'Hello World'
      end
    end

    options '/foo', { }, { 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'POST', 'HTTP_ACCESS_CONTROL_REQUEST_HEADERS' => 'bar' }

    assert last_response.headers.key?('Access-Control-Allow-Origin')
  end

  def test_conditional_get_support
    @app = Class.new(Chassis::WebApp) do
      get '/cached' do
        cache_control :public
        etag 'hash'
        'Hello World'
      end
    end

    get '/cached', { }, { "HTTP_IF_NONE_MATCH" => '"hash"' }

    assert_equal 304, last_response.status
  end

  def test_serves_compressed_responses
    @app = Class.new(Chassis::WebApp) do
      get '/zipped' do
        "We be zippin'"
      end
    end

    get '/zipped', { }, { "HTTP_ACCEPT_ENCODING" => 'gzip' }
    assert_equal 'gzip', last_response.headers.fetch('Content-Encoding')
  end
end
