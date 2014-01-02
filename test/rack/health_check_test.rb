require_relative '../test_helper'

class HealthCheckTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  class HelloWorld
    def call(env)
      [200, {'Content-Type' => 'text/plain' }, 'Hi']
    end
  end

  attr_reader :log, :app

  def setup
    @log = StringIO.new
    builder = Rack::Builder.new
    builder.use Chassis::Rack::Ping
    builder.run HelloWorld.new
    @app = builder.to_app
  end

  def test_returns_status_when_accessing_ping
    get '/ping'

    assert_equal 200, last_response.status
    assert_equal 'text/plain', last_response.content_type
    assert_equal 'pong', last_response.body
  end

  def test_allows_other_requests
    get '/foo'

    assert_equal 'Hi', last_response.body
  end
end
