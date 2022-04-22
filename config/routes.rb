require 'devise/rownd/custom_failure'

Devise::Rownd::Engine.routes.draw do
  post '/authenticate' => 'auth#authenticate'
  post '/sign_out' => 'auth#sign_out'
  post '/update_data' => 'auth#update_data'
  get '/healthz' => 'auth#healthz'
end
