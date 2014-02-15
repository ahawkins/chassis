module Chassis
  class MemoryRepo < BaseRepo
    def initialize
      @map = Repo::RecordMap.new
    end

    def create(record)
      record.id ||= next_id
      map.set record
    end

    def update(record)
      map.set record
    end

    def delete(record)
      map.delete record
    end

    def clear
      map.clear
    end

    def all(klass)
      map.all klass
    end

    def find(klass, id)
      map.get klass, id
    end

    private
    def map
      @map
    end

    def next_id
      @counter ||= 0
      @counter = @counter + 1
      @counter
    end
  end
end
