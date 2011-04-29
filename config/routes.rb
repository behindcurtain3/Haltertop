Haltertop::Application.routes.draw do
  resources :users
  resources :sessions,
    :only => [ :new, :create, :destroy ]

  root :to => "pages#home"

  match '/news'          => "pages#news"
  match '/getstarted'    => "pages#getstarted"
  match '/about'         => "pages#about"
  match '/contact'       => "pages#contact"

  match '/signin'        => "sessions#new"
  match '/signout'       => "session#destroy"
  match '/signup'        => "users#new"
end
