require_relative 'test_helper'

class StatusCheckTest < MiniTest::Unit::TestCase
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
    builder.use ::Chassis::StatusCheck
    builder.run HelloWorld.new
    @app = builder.to_app
  end

  def test_does_not_allow_any_robots
    get '/status'

    assert_equal 200, last_response.status
    assert_equal 'text/plain', last_response.content_type
    assert_equal 'Goliath online!', last_response.body
  end

  def test_allows_other_requests
    get '/foo'

    assert_equal 'Hi', last_response.body
  end
end
