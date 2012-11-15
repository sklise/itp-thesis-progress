class AuthenticationManager < Sinatra::Base
  set :erb, layout: :'../../views/layout'

  post '/unauthenticated' do
    session[:return_to] = env['warden.options'][:attempted_path]
    flash.error = env['warden'].message
    redirect '/session/login'
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    env['warden'].authenticate!
    flash.success = env['warden'].message
    if session[:return_to].nil?
      redirect '/'
    else
      redirect session[:return_to]
    end
  end

  # This should maybe be a delete request...
  get '/logout' do
    env['warden'].raw_session.inspect
    env['warden'].logout
    flash.success = 'Successfully logged out'
    redirect '/'
  end
end