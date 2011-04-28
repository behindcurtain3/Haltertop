Haltertop::Application.routes.draw do
  root :to => "pages#home"

	match 'signin' => "sessions#new"
end
