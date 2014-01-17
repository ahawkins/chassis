module Chassis
  module Persistance
    module ClassMethods
      def create(*args, &block)
        record = new(*args, &block)
        record.save
        record
      end

      def repo
        @repo ||= "#{name}Repo".constantize
      end
    end

    class << self
      def included(base)
        base.class_eval do
          attr_accessor :id
        end

        base.extend ClassMethods
      end
    end

    def save
      repo.save self
    end

    def delete
      repo.delete self
    end

    def new_record?
      id.nil?
    end

    def ==(o)
      if o.instance_of? self.class
        o && o.id == id
      else
        false
      end
    end

    def eql?(o)
      self == o
    end

    def hash
      id
    end

    def repo
      self.class.repo
    end

    def inspect
      "<#{self.class.name}:#{id}>"
    end
  end
end
