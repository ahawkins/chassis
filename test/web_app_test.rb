require_relative 'test_helper'

class WebAppTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  TestError = Class.new StandardError

  attr_reader :app

  def test_parses_json_bodies
    flunk
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
