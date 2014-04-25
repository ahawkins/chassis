module Chassis
  module ArrayUtils
    def extract_options!(array)
      array.last.is_a?(Hash) ? array.pop : { }
    end
    module_function :extract_options!
  end
end
