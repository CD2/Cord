require "cord/engine"
require "cord/base_api"

module Cord
  class << self
    mattr_accessor :action_writer_path
    self.action_writer_path = Rails.root.join '/actions.md'
  end
end
