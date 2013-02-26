class AuthenticationManager < Sinatra::Base
  set :erb, layout: :'../../views/layout'

  post '/unauthenticated' do
    session[:return_to] = env['warden.options'][:attempted_path]
    puts env['warden.options'][:attempted_path]
    flash.error = env['warden'].message if env['warden'].message
    redirect '/auth/login'
  end

  get '/login' do
    erb :login
  end

  # This should maybe be a delete request...
  get '/logout' do
    env['warden'].logout
    flash.success = "<p>Successfully logged out</p> <p>If this is a public computer, it is recommended to quit the browser.</p>"
    redirect '/'
  end

  get '/success' do
    erb :success, layout: false
  end

  post '/saml/callback' do
    saml_hash = request.env['omniauth.auth']['extra']['raw_info'].to_hash

    user = User.first_or_create netid: saml_hash['uid']

    user.update(first_name:  saml_hash['givenName']) if user.first_name.nil?
    user.update(last_name:  saml_hash['sn']) if user.last_name.nil?

    env['warden'].set_user user

    @current_user = user
    flash.success = env['warden'].message || "You've logged in as #{@current_user}"

    @return_to = session[:return_to]
    redirect '/auth/success'
  end
end