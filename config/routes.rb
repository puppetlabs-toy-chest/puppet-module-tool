ActionController::Routing::Routes.draw do |map|

  map.resources :releases

  map.root :controller => 'pages', :action => 'root'

  map.home '/home', :controller => 'pages', :action => 'home'
  
  map.resources :mods, :as => 'modules' do |mods|
    # TODO Implement Watches
    # mods.resources :watches
  end
  
  map.resources :tags

  map.devise_for :users
  map.resources :users, :member => {:switch => :post} do |users|
    users.resources :mods, :as => 'modules' do |mods|
      mods.resources :releases, :id => nil, :requirements => {:id => /.+/}, :collection => {:find => :get}
    end
    # TODO Implement TimelineEvents
    # users.resources :timeline_events, :as => 'events'
  end

  # Some vanity URLs
  map.vanity '/:id', :controller => 'users', :action => 'show'
  map.module '/:user_id/:id', :controller => 'mods', :action => 'show'
  map.formatted_module '/:user_id/:id.:extension', :controller => 'mods', :action => 'show'
  map.vanity_release '/:user_id/:mod_id/:id', :controller => 'releases', :action => 'show', :id => nil, :requirements => {:id => /.+/}
  map.formatted_vanity_release '/:user_id/:mod_id/:id.:extension', :controller => 'releases', :action => 'show', :id => nil, :requirements => {:id => /.+/}
  
  map.resource :pages, :collection => {:home => :get}

  if %w[test development].include?(RAILS_ENV)
    map.connect '/test', :controller => 'application', :action => 'test'
    map.connect '/test.:format', :controller => 'application', :action => 'test'
  end
  
end
