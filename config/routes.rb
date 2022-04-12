Devise::Rownd::Engine.routes.draw do
  post '/authenticate' => 'auth#authenticate'
  post '/sign_out' => 'auth#sign_out'
  get '/healthz' => 'auth#healthz'
end
