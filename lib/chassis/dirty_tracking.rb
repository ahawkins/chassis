require 'set'
require 'active_support/concern'

module Chassis
  module DirtyTracking
    extend ActiveSupport::Concern

    module ClassMethods
      def dirty_accessor(*names)
        names.each do |attribute|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{attribute}
              @#{attribute}
            end

            def #{attribute}=(_value)
              if #{attribute} != _value
                unless original_attributes.key?(:#{attribute})
                  original_attributes[:#{attribute}] = #{attribute}
                end

                dirty_attributes << :#{attribute}

                @#{attribute} = _value
              end
            end

            def #{attribute}_dirty?
              dirty_attributes.include? :#{attribute}
            end
            alias #{attribute}_changed? #{attribute}_dirty?

            def original_#{attribute}
              original_attributes[:#{attribute}]
            end
          RUBY
        end
      end
    end

    def initialize(*args)
      super
      clean!
    end

    def dirty_attributes
      @dirty_attributes ||= Set.new
    end

    def original_attributes
      @original_attributes ||= {}
    end

    def dirty?
      !dirty_attributes.empty?
    end
    alias changed? dirty?

    def clean!
      dirty_attributes.clear
      original_attributes.clear
    end

    def marshal_load(hash)
      super
      clean!
    end
  end
end
