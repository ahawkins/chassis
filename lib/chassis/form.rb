module Chassis
  UnknownFormFieldError = Chassis.error do |field|
     "#{field} given but not allowed."
  end

  class FormModule < Module
    module InstanceMethods
      def initialize(hash = {})
        assert_valid_keys! hash.symbolize_keys
        super
        yield self if block_given?
      end

      def values
        dirty_attributes
      end

      private
      def assert_valid_keys!(hash)
        return if accepted_keys.empty?

        hash.keys.each do |key|
          raise UnknownFormFieldError, key unless accepted_keys.include? key
        end
      end

      def accepted_keys
        self.class.accepted_keys
      end
    end

    module ClassMethods
      def attribute(name, type, options = {})
        accepted_keys << name.to_sym
        super(name, type, options)
      end

      def accepted_keys
        @accepted_keys ||= []
      end
    end

    def included(base)
      base.include Virtus.model
      base.extend ClassMethods
      base.include Virtus::DirtyAttribute
      base.include InstanceMethods
    end
  end

  class << self
    def form
      FormModule.new
    end
  end
end
