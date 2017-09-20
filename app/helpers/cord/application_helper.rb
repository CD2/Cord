module Cord
  module ApplicationHelper
    def cord_controller?
      Cord.in? parents
    end
  end
end
