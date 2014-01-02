module Chassis
  module Rack
    class Bouncer
      BOUNCERS = [
        lambda { |req| ; req.user_agent =~ /masscan/ }
      ]

      def initialize(app, &bouncer)
        @app, @bouncer = app, bouncer
      end

      def call(env)
        if bounce?(env)
          [403, { }, [ ]]
        else
          @app.call env
        end
      end

      def bounce?(env)
        request = ::Rack::Request.new env

        bouncers.any? do |bouncer|
          bouncer.call request
        end
      end

      def bouncers
        [BOUNCERS, @bouncer].flatten.compact
      end
    end
  end
end
