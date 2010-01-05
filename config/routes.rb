ActionController::Routing::Routes.draw do |map|

  map.resources :mods, :alias => 'modules'
  
  map.resources :users do |owner|
    owner.resources :namespaces do |ns|
      ns.resources :mods, :alias => 'modules'
    end
  end
  map.resources :organizations do |owner|
    owner.resources :namespaces do |ns|
      ns.resources :mods, :alias => 'modules'
    end
  end
  
  map.resource :session
  map.resource :pages, :collection => {
    :home => :get
  }

  map.root :controller => 'pages', :action => 'home'
  
end
