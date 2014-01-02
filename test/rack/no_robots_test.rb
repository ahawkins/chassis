require_relative '../test_helper'

class NoRobotsTest < MiniTest::Unit::TestCase
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
    builder.use Chassis::Rack::NoRobots
    builder.run HelloWorld.new
    @app = builder.to_app
  end

  def test_does_not_allow_any_robots
    get '/robots.txt'

    assert_includes last_response.body, 'Disallow: /'
    assert_includes last_response.body, 'User Agent: *'
  end

  def test_allows_other_requests
    get '/foo'

    assert_equal 'Hi', last_response.body
  end
end
