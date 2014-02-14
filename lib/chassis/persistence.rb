module Chassis
  module Persistence
    module ClassMethods
      def create(*args, &block)
        record = new(*args, &block)
        record.save
        record
      end

      def repo
        begin
          @repo ||= "#{name}Repo".constantize
        rescue NameError
          fail "#{name}Repo not defined! Define this method to specify a different repo"
        end
      end
    end

    class << self
      def included(base)
        base.class_eval do
          include Initializable
          include Equalizer.new(:id)

          attr_accessor :id
        end

        base.extend ClassMethods
      end
    end

    def save
      yield self if block_given?
      repo.save self
    end

    def delete
      repo.delete self
    end

    def new_record?
      id.nil?
    end

    def repo
      self.class.repo
    end
  end
end
