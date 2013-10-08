require_relative 'test_helper'
require 'stringio'

class RequestLoggerTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  class SetRackErrors
    def initialize(app, stream)
      @app, @stream = app, stream
    end

    def call(env)
      env['rack.errors'] = @stream
      @app.call env
    end
  end

  class HelloWorld
    def call(env)
      [200, {'Content-Type' => 'text/plain' }, 'Hi']
    end
  end

  attr_reader :log, :app

  def setup
    @log = StringIO.new
    builder = Rack::Builder.new
    builder.use SetRackErrors, log
    builder.use ::Chassis::RequestLogger
    builder.run HelloWorld.new
    @app = builder.to_app
  end

  def test_includes_the_params_in_the_log
    get '/', foo: 'bar'

    assert_logged 'foo'
    assert_logged 'bar'
  end

  def test_includes_the_path
    get '/this_path'

    assert_logged 'this_path'
  end

  def test_includes_the_status_code
    get '/this_path'

    assert_logged '200'
  end

  private
  def assert_logged(string)
    log.rewind
    content = log.read
    assert_includes content, string
  end
end

