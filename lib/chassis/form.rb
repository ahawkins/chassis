module Chassis
  class Form
    class UnknownField < StandardError ; end

    include Virtus.model
    include Virtus::Dirty

    class << self 
      def attribute(name, type, options = {})
        accepted_keys << name.to_sym
        super(name, type, options)
      end

      def accepted_keys
        @accepted_keys ||= []
      end
    end

    def initialize(hash = {})
      assert_valid_keys! hash.symbolize_keys
      super
      yield self if block_given?
    end

    def attributes
      dirty_attributes
    end

    private
    def assert_valid_keys!(hash)
      return if accepted_keys.empty?

      hash.keys.each do |key|
        raise UnknownField, key unless accepted_keys.include? key
      end
    end

    def accepted_keys
      self.class.accepted_keys
    end
  end
end
