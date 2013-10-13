module Chassis
  class StatusCheck
    def initialize(app)
      @app = app
    end

    def call(env)
      if env['PATH_INFO'] == '/status'
        [200, {'Content-Type' => 'text/plain'}, ['Goliath online!']]
      else
        @app.call env
      end
    end
  end
end
