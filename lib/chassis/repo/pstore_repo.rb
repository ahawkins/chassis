module Chassis
  class PStoreRepo < BaseRepo
    class AccessProxy < Chassis::Proxy
      def map
        __getobj__[:map] ||= Chassis::Repo::RecordMap.new
      end
    end

    class PStoreMap
      def initialize(pstore)
        @pstore = AccessProxy.new pstore
      end

      def clear
        pstore.transaction do
          pstore.map.clear
        end
      end

      def all(klass)
        pstore.transaction do
          pstore.map.all klass
        end
      end

      def get(klass, id)
        pstore.transaction do
          pstore.map.get klass, id
        end
      end

      def set(record)
        pstore.transaction do
          pstore.map.set record
        end
      end

      def delete(record)
        pstore.transaction do
          pstore.map.delete record
        end
      end

      private
      def pstore
        @pstore
      end
    end

    def initialize(pstore)
      @map = PStoreMap.new pstore
    end
  end
end
