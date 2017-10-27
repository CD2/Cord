require "cord/engine"
require "cord/base_api"

module Cord
  class << self
    mattr_accessor :action_writer_path
    mattr_accessor :enable_postgres_rendering
    self.action_writer_path = '/'
    self.enable_postgres_rendering = false
  end
end
