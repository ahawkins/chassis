module Chassis
  module Observable
    def add_observer(observer)
      @observers ||= []
      @observers << observer
    end

    private
    def notify_observers(event, *args)
      return unless defined? @observers

      @observers.each do |observer|
        if observer.respond_to? event
          observer.send event, *[self, args].flatten
        end
      end
    end
  end
end
