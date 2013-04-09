class AdminApp < Sinatra::Base
  register Sinatra::ThesisApp

  before do
    env['warden'].authenticate!
    @current_user = env['warden'].user
    require_admin
  end

  get '/' do
    @site_config = SiteConfig.first
    erb :'admin/config'
  end

  post '/' do
    @site_config = SiteConfig.first

    if params[:thesis_lock].nil?
      params[:thesis_lock] = false
    end

    @site_config.update(params)

    redirect '/admin'
  end

  # tags
end