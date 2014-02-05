require 'set'

module Chassis
  class DirtySession < Proxy
    def initialize(*args)
      super
      @original_values  = { }
      @new_values = { }
    end

    def clean?
      new_values.empty?
    end

    def dirty?
      !clean?
    end

    def original_values
      @original_values
    end

    def new_values
      @new_values
    end

    def changes
      Set.new original_values.keys
    end

    def reset!
      original_values.clear
      new_values.clear
    end

    def method_missing(name, *args, &block)
      raise MissingObject, name unless __getobj__

      if writer_method?(name)
        handle_writer_method name, *args, &block
      elsif changed_method?(name)
        handle_changed_method name
      elsif original_method?(name)
        handle_original_method name
      else
        __getobj__.send name, *args, &block
      end
    end

    def respond_to_missing?(name, include_private = false)
      if changed_method?(name) || original_method?(name)
        __getobj__.respond_to? reader_method(name)
      else
        super
      end
    end

    private
    def handle_writer_method(name, *args, &block)
      method_key = reader_method name

      original_value = __getobj__.send method_key
      new_value = __getobj__.send name, *args, &block

      if new_value != original_value
        original_values[method_key] = original_value unless original_values.key? method_key
        new_values[method_key] = new_value
      end

      new_value
    end

    def writer_method?(name)
      name =~ /=$/
    end

    def reader_method(name)
      method_name = name.to_s

      if writer_method? method_name
        method_name.match(/(.+)=$/)[1].to_sym
      elsif changed_method? method_name
        method_name.match(/(.+)_changed\?$/)[1].to_sym
      elsif original_method? method_name
        method_name.match(/original_(.+)$/)[1].to_sym
      end
    end

    def original_method?(name)
      name =~ /original_.+$/
    end

    def changed_method?(name)
      name =~ /_changed\?$/
    end

    def handle_changed_method(name)
      original_values.key? reader_method(name)
    end

    def handle_original_method(name)
      original_values[reader_method(name)]
    end
  end
end
