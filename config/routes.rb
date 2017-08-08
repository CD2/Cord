Cord::Engine.routes.draw do
  get '/*api/schema', to: 'api_base#schema'
  get '/*api/ids', to: 'api_base#ids'
  get '/*api/perform/:action_name', to: 'api_base#perform'
  get '/*api', to: 'api_base#index'
end
