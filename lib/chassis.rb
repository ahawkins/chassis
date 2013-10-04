require "chassis/version"

require 'multi_json'
require 'sinatra'
require 'manifold'
require 'rack/contrib/bounce_favicon'
require 'rack/contrib/post_body_content_type_parser'
require 'rack/builder_shim_patch'

require 'harness'

require 'virtus'
require 'virtus/dirty'

require 'active_support/concern'

module Chassis
end

require_relative 'chassis/web_app'
require_relative 'chassis/form'
require_relative 'chassis/repo'

require_relative 'chassis/dirty_tracking'
require_relative 'chassis/observable'
