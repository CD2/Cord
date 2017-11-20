Cord::Engine.routes.draw do
  get '/*api/schema', to: 'api_base#schema'
  get '/*api/ids', to: 'api_base#ids'
  post '/*api/perform/:action_name', to: 'api_base#perform'
  get '/*api/collection_select/:label', to: 'api_base#collection_select'
  get '/*api', to: 'api_base#index'
end
