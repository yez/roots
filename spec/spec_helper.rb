require 'pry'
require 'action_dispatch/routing/inspector'


module ActionDispatch
  module Routing
    class RouteWrapper < SimpleDelegator
      %i[
        endpoint constraints rack_app
        verb path name regexp
        json_regexp reqs controller action
        internal? engine?
        ].each do |method|
          define_method(method) {}
        end
    end
  end
end

module Rails
  module Engine; end
end