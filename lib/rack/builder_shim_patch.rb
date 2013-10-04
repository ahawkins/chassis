module Rack
  class Builder
    def shim(middleware, *args, &block)
      @use.unshift proc { |app| middleware.new(app, *args, &block) }
    end
  end
end
