require "chassis/version"

require 'logger-better'

require 'sinatra'
require 'manifold'
require 'rack/contrib/bounce_favicon'
require 'rack/contrib/post_body_content_type_parser'

require 'harness'
require 'harness/rack'

require 'virtus'
require 'virtus/dirty_attribute'

require 'prox'

require 'faraday'

require 'breaker'

module Chassis
  Proxy = Prox

  class << self
    def stream
      @stream
    end

    def stream=(stream)
      @stream = stream
    end
  end
end

require_relative 'chassis/core_ext/string'
require_relative 'chassis/core_ext/hash'

require_relative 'chassis/error'

require_relative 'chassis/inflector'

require_relative 'chassis/logger'

require_relative 'chassis/faraday'

require_relative 'chassis/form'

require_relative 'chassis/persistence'

require_relative 'chassis/initializable'

require_relative 'chassis/observable'

require_relative 'chassis/dirty_session'

require_relative 'chassis/circuit_panel'

require_relative 'chassis/strategy'

require_relative 'chassis/registry'

require_relative 'chassis/repo'

require_relative 'chassis/delegate'

require_relative 'chassis/rack/bouncer'
require_relative 'chassis/rack/builder_shim_patch'
require_relative 'chassis/rack/health_check'
require_relative 'chassis/rack/instrumentation'
require_relative 'chassis/rack/no_robots'

require_relative 'chassis/web_service'

Chassis.repo.register :memory, Chassis::MemoryRepo.new
Chassis.repo.register :null, Chassis::NullRepo.new
Chassis.repo.use :memory
