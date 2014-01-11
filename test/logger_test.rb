require_relative 'test_helper'

class LoggerTest < MiniTest::Unit::TestCase
  def test_log_level_defaults_to_env_variable
    with_env :warn do
      logger = Chassis::Logger.new $stdout
      assert_equal Logger::WARN, logger.level
    end
  end

  def test_log_deafults_debug_without_env_variable
    refute ENV['LOG_LEVEL'], "Precondition: LOG_LEVEL must be blank"

    logger = Chassis::Logger.new $stdout
    assert_equal Logger::DEBUG, logger.level
  end

  def test_log_dev_defaults_to_chassis_stream
    Chassis.stream = StringIO.new

    logger = Chassis::Logger.new
    logger.debug 'test'

    Chassis.stream.rewind
    content = Chassis.stream.read

    assert_includes content, 'test'
  end

  private
  def with_env(name)
    original_env = ENV['LOG_LEVEL']
    ENV['LOG_LEVEL'] = name.to_s

    yield
  ensure
    if original_env
      ENV['LOG_LEVEL'] = original_env
    else
      ENV.delete 'LOG_LEVEL'
    end
  end
end
