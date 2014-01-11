module Chassis
  class Logger < ::Logger
    def initialize(logdev = Chassis.stream, shift_age = 0, shift_size = 1048576)
      super
      self.level = ENV['LOG_LEVEL'].to_sym if ENV['LOG_LEVEL']
    end
  end
end
