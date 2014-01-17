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

Proxy = Prox

module Chassis
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

require_relative 'chassis/inflector'

require_relative 'chassis/logger'

require_relative 'chassis/faraday'

require_relative 'chassis/form'
require_relative 'chassis/repo'

require_relative 'chassis/persistance'

require_relative 'chassis/hash_initializer'

require_relative 'chassis/dirty_tracking'
require_relative 'chassis/observable'

require_relative 'chassis/rack/bouncer'
require_relative 'chassis/rack/builder_shim_patch'
require_relative 'chassis/rack/health_check'
require_relative 'chassis/rack/instrumentation'
require_relative 'chassis/rack/no_robots'

require_relative 'chassis/web_service'

Chassis::Repo.backend = Chassis::Repo::InMemoryAdapter.new
Chassis::Repo.backend.initialize_storage!
