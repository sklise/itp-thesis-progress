class Main < Sinatra::Base
  register WillPaginate::Sinatra
  register Sinatra::ThesisApp

  # Load up Redis to cache list of users and list of pages. This will make
  # matching top level paths such as "/:netid" faster than querying the db.
  uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://localhost:6379")
  redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

  # Flush the redis info.
  redis.del('itpthesis:users')
  redis.del('itpthesis:pages')
  # Add all students and pages to Redis
  User.students.each {|s| redis.sadd('itpthesis:users', s.netid) }
  Page.all.each {|p| redis.sadd('itpthesis:pages', p.slug) }

  # Set up this controller to handle all static files since this controller is
  # mapped to the root url.
  set :static, true
  set :public_folder, Proc.new { File.join(File.dirname(__FILE__), "../../public") }

  get '/' do
    # If someone is signed in, call the /dashboard route
    if env['warden'].authenticated?
      status, headers, body = call env.merge("PATH_INFO" => '/dashboard')
      [status, headers, body]
    # Otherwise, send the static welcome page.
    else
      File.read(File.join(settings.public_folder, 'welcome.html'))
    end
  end

  # Dashboard page. Create a dashboard to match all user roles.
  get '/dashboard' do
    env['warden'].authenticate!
    @current_user = env['warden'].user

    if @current_user.student?
      @drafts = @current_user.posts.drafts
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

  # Check top level against student netids, redirect to student page if there
  # is a match, otherwise pass to next route.
  get '/:netid' do
    if redis.sismember('itpthesis:users', params[:netid])
      redirect "/students/#{params[:netid]}"
    else
      pass
    end
  end

  #############################################################################
  #
  # PAGES
  #
  #############################################################################

  get '/:page' do
    env['warden'].authenticate!
    @current_user = env['warden'].user

    pass if !redis.sismember('itpthesis:pages', params[:page])

    @page = Page.first(slug: params[:page])

    StatHat::API.ez_post_value("Pages : View : #{@page.title}", ENV['STATHAT_EMAIL'], 1)

    erb :'pages/show'
  end

  get '/page/new' do
    env['warden'].authenticate!
    @current_user = env['warden'].user
    require_admin

    @page = Page.new
    erb :'pages/new'
  end

  post '/page/new' do
    env['warden'].authenticate!
    @current_user = env['warden'].user
    require_admin

    @page = Page.create(params[:page_form])

    redirect "/#{@page.slug}"
  end

  get '/:page/edit' do
    env['warden'].authenticate!
    @current_user = env['warden'].user
    require_admin

    @pages = Page.all
    pass if !@pages.slugs.include?(params[:page])
    @page = @pages.first(slug: params[:page])

    StatHat::API.ez_post_value("Pages : Edit : #{@page.title}", ENV['STATHAT_EMAIL'], 1)

    erb :'pages/edit'
  end

  post '/:page' do
    env['warden'].authenticate!
    @current_user = env['warden'].user
    require_admin

    @page = Page.first(slug: params[:page])
    @page.update(params[:page_form])

    StatHat::API.ez_post_value("Pages : Update : #{@page.title}", ENV['STATHAT_EMAIL'], 1)
    redirect "/#{@page.slug}"
  end

  # Route to only use in Development to set your user to any netid to view the
  # site as another person.
  unless ENV['RACK_ENV'] == 'production'
    get '/set_user/:netid' do
      @user = User.first netid: params[:netid]
      env['warden'].set_user @user
      @user.to_json
    end
  end
end