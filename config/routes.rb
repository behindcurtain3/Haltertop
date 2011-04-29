Haltertop::Application.routes.draw do
  root :to => "pages#home"

  match 'news'          => "pages#news"
  match 'getstarted'    => "pages#getstarted"
	match 'signin'        => "sessions#new"
  match 'about'         => "pages#about"
  match 'contact'       => "pages#contact"
end
