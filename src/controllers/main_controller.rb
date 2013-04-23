class Main < Sinatra::Base
  register WillPaginate::Sinatra
  register Sinatra::ThesisApp

  uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://localhost:6379")
  redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

  redis.del('itpthesis:users')
  redis.del('itpthesis:pages')

  User.students.each do |s|
    redis.sadd('itpthesis:users', s.netid)
  end

  Page.all.each do |p|
    redis.sadd('itpthesis:pages', p.slug)
  end

  set :static, true
  set :public_folder, Proc.new { File.join(File.dirname(__FILE__), "../../public") }

  before do
    env['warden'].authenticate!
    @current_user = env['warden'].user
  end

  get '/' do
    env['warden'].authenticate!

    if @current_user.student?
      @drafts = @current_user.posts.drafts
      @assignments = @current_user.sections.assignments.published.all
      @comments = @current_user.posts.comments.all(order: :created_at.desc, limit: 10)
      @announcements = Announcement.published.all(limit: 10)

      @recent_posts = @current_user.sections.first.students.posts.published.paginate(page: 1)

      StatHat::API.ez_post_value("Dashboard : Student", ENV['STATHAT_EMAIL'], 1)

      erb :'dashboards/student'
    elsif @current_user.faculty?
      @sections = Section.all(year: 2013)
      StatHat::API.ez_post_value("Dashboard : Faculty", ENV['STATHAT_EMAIL'], 1)
      erb :'dashboards/faculty'
    elsif @current_user.admin?
      # @announcement_drafts = @current_user.announcements.drafts
      @announcements = Announcement.published.all(limit: 10)
      @sections = @current_user.sections
      @comments = @current_user.sections.users.posts.comments.all(order: :created_at.desc, limit: 20, :user_id.not => @current_user.id, read: false)

      @drafts = @current_user.announcements.drafts

      StatHat::API.ez_post_value("Dashboard : Admin", ENV['STATHAT_EMAIL'], 1)
      erb :'dashboards/advisor'
    else
      @sections = Section.all(year: 2013)
      StatHat::API.ez_post_value("Dashboard : Provisional", ENV['STATHAT_EMAIL'], 1)
      erb :'dashboards/provisional'
    end
  end

  #############################################################################
  #
  # PAGES
  #
  #############################################################################

  get '/:page' do

    redirect "/students/#{params[:page]}" if redis.sismember('itpthesis:users', params[:page])

    pass if !redis.sismember('itpthesis:pages', params[:page])

    @page = Page.first(slug: params[:page])

    StatHat::API.ez_post_value("Pages : View : #{@page.title}", ENV['STATHAT_EMAIL'], 1)

    erb :'pages/show'
  end

  get '/page/new' do
    require_admin
    @page = Page.new
    erb :'pages/new'
  end

  post '/page/new' do
    require_admin

    @page = Page.create(params[:page_form])

    redirect "/#{@page.slug}"
  end

  get '/:page/edit' do
    require_admin
    @pages = Page.all
    pass if !@pages.slugs.include?(params[:page])
    @page = @pages.first(slug: params[:page])

    StatHat::API.ez_post_value("Pages : Edit : #{@page.title}", ENV['STATHAT_EMAIL'], 1)

    erb :'pages/edit'
  end

  post '/:page' do
    require_admin
    @page = Page.first(slug: params[:page])
    @page.update(params[:page_form])

    StatHat::API.ez_post_value("Pages : Update : #{@page.title}", ENV['STATHAT_EMAIL'], 1)
    redirect "/#{@page.slug}"
  end

  unless ENV['RACK_ENV'] == 'production'
    get '/set_user/:netid' do
      @user = User.first netid: params[:netid]
      env['warden'].set_user @user
      @user.to_json
    end
  end
end