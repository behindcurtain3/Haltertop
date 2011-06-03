Haltertop::Application.routes.draw do
  match '/auth/facebook' => "sessions#redirect"

	resources :users
  resources :sessions,
    :only => [ :new, :create, :destroy ]

	# games paths, no one can edit or destroy a game
	resources :games, :except => [ :edit, :destroy ] do
		get 'move', :on => :member
    get 'pieces', :on => :member
	end

  root :to => "pages#home"

  match '/about'         => "pages#about"
  match '/contact'       => "pages#contact"

  match '/signin'        => "sessions#new"
  match '/signout'       => "sessions#destroy"
  match '/signup'        => "users#new"

	match '/play'					 => "games#create"
end
