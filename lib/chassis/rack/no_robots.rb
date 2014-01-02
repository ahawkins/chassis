module Chassis
  module Rack
    class NoRobots
      def initialize(app)
        @app = app
      end

      def call(env)
        if env['PATH_INFO'] == '/robots.txt'
          [200, {'Content-Type' => 'text/plain'}, [robots_txt]]
        else
          @app.call env
        end
      end

      def robots_txt
<<-txt
User Agent: *
Disallow: /
txt
      end
    end
  end
end
