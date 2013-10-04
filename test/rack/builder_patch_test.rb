require_relative '../test_helper'

class RackBuilderPatchTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  class OrderPrinter
    def call(env)
      [200, {'Content-Type' => 'text/plain'}, [ env['order'].join(',') ]]
    end
  end

  class OrderedMiddleware
    def initialize(app, position)
      @app, @position = app, position
    end

    def call(env)
      env['order'] ||= []
      env['order'] << @position
      @app.call env
    end
  end

 attr_reader :app 

  def test_should_be_able_to_insert_middlewares_at_the_top
    @app = Rack::Builder.app do
      shim OrderedMiddleware, 2
      shim OrderedMiddleware, 1
      run OrderPrinter.new
    end

    get '/'
    assert_equal '1,2', last_response.body
  end
end
