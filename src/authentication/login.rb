class AuthenticationManager < Sinatra::Base
  post '/unauthenticated' do
    session[:return_to] = env['warden.options'][:attempted_path]
    flash.error = env['warden'].message
    redirect to '/login'
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    env['warden'].authenticate!
    flash.success = env['warden'].message
    redirect session[:return_to]
  end

  # This should maybe be a delete request...
  post '/logout' do
    env['warden'].raw_session.inspect
    env['warden'].logout
    flash.success = 'Successfully logged out'
    redirect '/'
  end

  not_found do
    flash.error = "not found"
    redirect '/'
  end
end