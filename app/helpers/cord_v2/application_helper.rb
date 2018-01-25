module CordV2
  module ApplicationHelper
    def cord_controller?
      CordV2.in? self.class.parents
    end
  end
end
