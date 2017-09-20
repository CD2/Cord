module Cord
  class ApplicationHelper
    def cord_controller?
      Cord.in? parents
    end
  end
end
