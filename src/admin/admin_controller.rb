class AdminApp < Sinatra::Base
  set :views, Proc.new { File.join(root, "views") }
  set :logging, true
  set :enable_cache, true
  set :erb, layout: :'../../views/layout'

  if ENV['RACK_ENV'] == 'production'
    set :raise_errors, Proc.new { false }
    set :show_exceptions, false

    error do
      StatHat::API.ez_post_value("ERROR : #{request.fullpath}", ENV['STATHAT_EMAIL'], 1)

      email_body = ""

      if @current_user
        email_body += "CURRENT_USER: #{@current_user}\n\n"
      end

      email_body += env['sinatra.error'].backtrace.join("\n")
      send_email("ERROR: #{request.fullpath}", email_body)

      erb :'../../views/error'
    end
  end

  before do
    env['warden'].authenticate!
    @current_user = env['warden'].user
    require_admin
  end

  get '/' do
    @site_config = SiteConfig.first
    erb :config
  end

  post '/' do
    @site_config = SiteConfig.first

    if params[:thesis_lock].nil?
      params[:thesis_lock] = false
    end

    @site_config.update(params)

    redirect '/admin'
  end

  not_found do
    flash.error = "Could not find #{request.fullpath}"
  end
end