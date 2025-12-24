Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "stats#overview"

  resources :stats, only: [:index] do
    collection do
      get :overview
      get :head_to_head
      get :team_names
      get :high_low_scores
      get :season_trends
      get :rivalries
      get :transactions
    end
  end
end
