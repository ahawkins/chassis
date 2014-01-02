require "chassis/version"

require 'multi_json'
require 'sinatra'
require 'manifold'
require 'rack/contrib/bounce_favicon'
require 'rack/contrib/post_body_content_type_parser'

require 'harness'
require 'harness/rack'

require 'virtus'
require 'virtus/dirty'

require 'prox'

Proxy = Prox

module Chassis
end

require_relative 'chassis/form'
require_relative 'chassis/repo'

require_relative 'chassis/hash_initializer'

require_relative 'chassis/dirty_tracking'
require_relative 'chassis/observable'

require_relative 'chassis/rack/bouncer'
require_relative 'chassis/rack/builder_shim_patch'
require_relative 'chassis/rack/health_check'
require_relative 'chassis/rack/instrumentation'
require_relative 'chassis/rack/no_robots'
