module Chassis
  class Repo
    class LazyAssociation < Proxy
      def initialize(repo, id)
        @repo, @id = repo, id
      end

      def id
        @id
      end

      def class
        @repo.object_class
      end

      def repo
        @repo
      end

      def instance_of?(klass)
        self.class == klass
      end

      def is_a?(klass)
        instance_of?(klass) || self.class > klass
      end

      def kind_of?(klass)
        is_a? klass
      end

      def ==(other)
        if other.instance_of? self.class
          other.id == id
        else
          other.repo == repo && other.id == id
        end
      end

      def eql?(other)
        self == other
      end

      def materialize
        @object ||= repo.find id
      end

      def __getobj__
        materialize
      end

      def inspect
        "#<LazyAssociation:#{object_id} @repo=#{repo} @id=#{id}>"
      end
    end
  end
end
