class AuthenticationManager < Sinatra::Base
  set :erb, layout: :'../../views/layout'

  post '/unauthenticated' do
    session[:return_to] = env['warden.options'][:attempted_path]
    puts env['warden.options'][:attempted_path]
    flash.error = env['warden'].message || "You've gotta log in"
    redirect '/auth/login'
  end

  get '/login' do
    redirect "/auth/saml"
  end

  # This should maybe be a delete request...
  get '/logout' do
    env['warden'].logout
    flash.success = 'Successfully logged out'
    redirect '/'
  end

  post '/saml/callback' do
    saml_hash = request.env['omniauth.auth']['extra']['raw_info'].to_hash

    user = User.first_or_create netid: saml_hash['uid']

    user.update(first_name:  saml_hash['givenName']) if user.first_name.nil?
    user.update(last_name:  saml_hash['sn']) if user.last_name.nil?

    env['warden'].set_user user

    @current_user = user
    flash.success = env['warden'].message

    if session[:return_to].nil?
      redirect '/'
    else
      redirect session[:return_to]
    end
  end
end