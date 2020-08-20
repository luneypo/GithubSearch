Rails.application.routes.draw do

  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"

  post "/graphql", to: "graphql#execute"
  root 'home#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  post '/search' ,to: 'home#search'
  post '/profile' , to: 'home#profile'
  post '/repo' , to: 'home#repo'
  get '/delete_history', to: 'home#delete_history', as: 'delete_history'
  get '/history', to: 'home#history'
end
