require "chassis/version"

require 'sinatra'

module Chassis
  class WebApp < Sinatra::Base
    configure do
      # Don't log them. We'll do that ourself
      set :dump_errors, false

      # Don't capture any errors. Throw them up the stack
      set :raise_errors, true

      # Disable internal middleware for presenting errors
      # as useful HTML pages
      set :show_exceptions, false
    end
  end
end
