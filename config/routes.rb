Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'home#index'

  resources :stats, only: [:index] do
    collection do
      get :head_to_head
      get :recaps
      get :team_names
    end
  end
end
