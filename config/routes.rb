ActionController::Routing::Routes.draw do |map|

  map.resources :mods, :alias => 'modules'

  map.devise_for :user
  map.resource :user
  
  map.resource :pages, :collection => {
    :home => :get
  }

  map.root :controller => 'pages', :action => 'home'
  
end
