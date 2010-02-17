ActionController::Routing::Routes.draw do |map|

  map.resources :mods, :as => 'modules'
  map.resources :tags

  map.devise_for :users
  map.resources :users do |users|
    users.resources :mods, :as => 'modules'
  end
  map.vanity '/:id', :controller => 'users', :action => 'show'
  map.module '/:user_id/:id', :controller => 'mods', :action => 'show'
  map.formatted_module '/:user_id/:id.:extension', :controller => 'mods', :action => 'show'
  
  map.resource :pages, :collection => {
    :home => :get
  }

  map.root :controller => 'pages', :action => 'home'
  
end
