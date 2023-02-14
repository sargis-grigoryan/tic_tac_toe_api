Rails.application.routes.draw do
  resources :steps, only: [:index, :show, :create]

  get 'game(/:game_id)', to: 'game#display_board'
end