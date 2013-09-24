require_relative 'test_helper'

class WebAppTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  TestError = Class.new StandardError

  attr_reader :app

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
end
