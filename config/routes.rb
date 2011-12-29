RailsEmberjsDemo::Application.routes.draw do
  resources :items
  root :to => "home#index"
end
