require 'json'
require 'yaml'

module Chassis
  module Serializable
    module ClassMethods
      def from_hash(hash)
        new.from_hash(hash)
      end

      def from_json(json)
        from_hash JSON.load(json)
      end

      def from_yaml(yaml)
        from_hash YAML.load(yaml)
      end
    end

    class << self
      def included(base)
        base.extend ClassMethods
      end
    end

    def marshal_dump
      fail NotImplementedError, 'subclass must implement marshal_dump'
    end

    def marshal_load(hash)
      fail NotImplementedError, 'subclass must implement marshal_load'
    end

    def to_hash
      marshal_dump
    end
    alias_method :to_h, :to_hash

    def to_json
      JSON.dump marshal_dump
    end

    def to_yaml
      YAML.dump marshal_dump
    end

    def from_hash(hash)
      marshal_load HashUtils.symbolize(hash)
      self
    end
  end
end
