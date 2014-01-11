require_relative '../test_helper'

class RackBouncer < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  class HelloWorld
    def call(env)
      [200, {'Content-Type' => 'text/plain' }, 'Hi']
    end
  end

  attr_reader :app

  def setup
    builder = Rack::Builder.new
    builder.use Chassis::Rack::Bouncer
    builder.run HelloWorld.new
    @app = builder.to_app
  end

  def test_bouncers_masscan
    get '/', { } , 'HTTP_USER_AGENT' => 'masscan/1.0 (https://github.com/robertdavidgraham/masscan)'
    assert_equal 403, last_response.status
  end

  def test_can_supply_a_custom_bouncer
    builder = Rack::Builder.new
    builder.use Chassis::Rack::Bouncer do |req|
      true
    end
    builder.run HelloWorld.new
    @app = builder.to_app

    get '/'
    assert_equal 403, last_response.status
  end

  def test_allows_other_requests
    get '/foo'
    assert_equal 'Hi', last_response.body
  end
end
