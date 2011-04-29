Haltertop::Application.routes.draw do
  root :to => "pages#home"

  match 'news' => "pages#news"
	match 'signin' => "sessions#new"
end
