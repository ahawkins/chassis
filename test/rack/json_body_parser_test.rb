require_relative '../test_helper'

class JsonBodyParserTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  class EchoServer
    def call(env)
      request = Rack::Request.new env
      [200, {'Content-Type' => 'text/plain'}, [JSON.dump(request.params)]]
    end
  end

  attr_reader :app

  def setup
    @app = Rack::Builder.app do
      use Chassis::Rack::JsonBodyParser
      run EchoServer.new
    end
  end

  def test_parses_json_requests
    post '/', JSON.dump({foo: 'bar'}), 'CONTENT_TYPE' => 'application/json'

    params = JSON.load last_response.body
    assert_equal 'bar', params.fetch('foo')
  end

  def test_handles_empty_get_requests
    get '/', { }, { 'CONTENT_TYPE' => 'application/json' }
    assert_equal 200, last_response.status
  end

  def test_json_parse_errors_return_400
    post '/', 'foo=bar', 'CONTENT_TYPE' => 'application/json'
    assert_equal 400, last_response.status
  end
end
