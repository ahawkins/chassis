module Chassis
  module HashInitializer
    def initialize(values = {})
      super()
      values.each_pair do |key, value|
        send "#{key}=", value
      end
    end
  end
end
