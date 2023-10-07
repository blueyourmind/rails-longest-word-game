Rails.application.routes.draw do
  # Routes for the GamesController
  get '/new', to: 'games#new'
  post '/score', to: 'games#score'
end
