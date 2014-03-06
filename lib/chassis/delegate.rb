module Chassis
  DelegationError = Chassis.error do |method, delegate|
    "Cannot delegate #{method} without #{delegate}"
  end

  class Delegation < Module
    def initialize(*methods, delegate:)
      methods.each do |method|
        define_method method do |*args, &block|
          object = send delegate
          fail DelegationError.new method, delegate unless object
          object.send(method, *args, &block)
        end
      end
    end
  end

  class << self
    def delegate(*methods, to:)
      Delegation.new *methods, delegate: to
    end
  end
end
