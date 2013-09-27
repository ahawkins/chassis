require_relative 'test_helper'

class ObservableTest < MiniTest::Unit::TestCase
  class Ship
    include Chassis::Observable

    def sink!(command)
      notify_observers :sink, command
    end
  end

  class Watchtower
    def sink(ship, command)

    end
  end

  def test_includes_the_object_in_notifications
    ship = Ship.new
    observer = Watchtower.new

    observer.expects(:sink).with(ship, 'abandon ship!')

    ship.add_observer observer
    ship.sink! 'abandon ship!'
  end
end
