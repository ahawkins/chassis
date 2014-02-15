module Chassis
  class MemoryRepo < BaseRepo
    def initialize
      @map = Repo::RecordMap.new
    end
  end
end
