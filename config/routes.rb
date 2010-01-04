ActionController::Routing::Routes.draw do |map|
  map.resources :users
  map.resources :mods, :alias => :modules
  map.resource :session
  map.resource :pages, :collection => {
    :home => :get
  }

  map.root :controller => 'pages', :action => 'home'
end
