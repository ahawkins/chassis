module Chassis
  class << self
    def error(*args, &block)
      Tnt.boom *args, &block
    end
  end
end
