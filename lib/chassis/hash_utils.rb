module Chassis
  module HashUtils
    def symbolize(hash)
      hash.inject({}) do |memo, pair|
        key, value = pair

        if value.is_a? Hash
          memo.merge! key.to_sym => symbolize(value)
        else
          memo.merge! key.to_sym => value
        end
      end
    end
    module_function :symbolize
  end
end
