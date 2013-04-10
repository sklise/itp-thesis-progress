class AdminApp < Sinatra::Base
  register Sinatra::ThesisApp

  before do
    env['warden'].authenticate!
    @current_user = env['warden'].user
  end

  get '/' do
    if @current_user.admin?
      @site_config = SiteConfig.first
      erb :'admin/config'
    else
      erb :'admin/profile'
    end

  end

  post '/' do
    if @current_user.admin?
      @site_config = SiteConfig.first

      if params[:thesis_lock].nil?
        params[:thesis_lock] = false
      end

      @site_config.update(params)
    else
      @user = User.get @current_user.id

      @user.preferred_first = params[:preferred_first]
      @user.preferred_last = params[:preferred_last]

      @user.save
    end

    redirect '/admin'
  end

  # tags
end