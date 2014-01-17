module Chassis
  module Initializable
    def initialize(values = {})
      super()
      values.each_pair do |key, value|
        send "#{key}=", value
      end
      yield self if block_given?
    end
  end
end
