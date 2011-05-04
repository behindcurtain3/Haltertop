Haltertop::Application.routes.draw do
  resources :users
  resources :sessions,
    :only => [ :new, :create, :destroy ]

	# games paths, no one can edit or destroy a game
	resources :games, :except => [ :edit, :destroy ] do
		get 'move', :on => :member
	end

	resources :boards,
		:except => [ :new, :edit, :create, :destroy, :index ]

  root :to => "pages#home"

  match '/about'         => "pages#about"
  match '/contact'       => "pages#contact"

  match '/signin'        => "sessions#new"
  match '/signout'       => "sessions#destroy"
  match '/signup'        => "users#new"

	match '/play'					 => "games#create"
end
