require_relative '../test_helper'

class RackInstrumentationTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  class HelloWorld
    def call(env)
      [200, {'Content-Type' => 'text/plain' }, 'Hi']
    end
  end

  attr_reader :app

  def setup
    Harness.config.collector = Harness::FakeCollector.new
    Harness.config.queue = Harness::SyncQueue.new

    builder = Rack::Builder.new
    builder.use Chassis::Rack::Instrumentation
    builder.run HelloWorld.new
    @app = builder.to_app
  end

  def test_adds_the_x_runtime_header
    get '/foo'

    assert_equal 'Hi', last_response.body

    assert last_response['X-Runtime']
  end

  def test_instruments_with_harness
    get '/foo'

    refute_empty Harness.collector.timers
    assert_equal 'rack.request.all', Harness.collector.timers.first.name
  end
end
