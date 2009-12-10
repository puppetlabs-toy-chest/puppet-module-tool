ActionController::Routing::Routes.draw do |map|
  map.resources :users
  map.resource :session
end
