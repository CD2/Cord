module CordV2
  class Engine < ::Rails::Engine
    isolate_namespace CordV2
    # config.autoload_paths << File.expand_path '../app/apis', __FILE__
  end
end
