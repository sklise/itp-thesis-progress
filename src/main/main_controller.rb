class Main < Sinatra::Base
  register WillPaginate::Sinatra

  set :views, Proc.new { File.join(root, "views") }
  set :static, true
  set :logging, true
  set :cache, Dalli::Client.new
  set :enable_cache, true
  set :public_folder, Proc.new { File.join(root, "../../public") }
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
  end

  get '/' do
    if env['warden'].authenticated?

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
      else
        # @announcement_drafts = @current_user.announcements.drafts
        @announcements = Announcement.published.all(limit: 10)
        @sections = @current_user.sections
        @comments = @current_user.sections.users.posts.comments.all(order: :created_at.desc, limit: 20, :user_id.not => @current_user.id, read: false)

        StatHat::API.ez_post_value("Dashboard : Admin", ENV['STATHAT_EMAIL'], 1)
        erb :'dashboards/advisor'
      end
    else
      erb :front_page
    end
  end

  #############################################################################
  #
  # PAGES
  #
  #############################################################################

  get '/:page' do
    @pages = Page.all

    pass if !@pages.slugs.include?(params[:page])

    @page = @pages.first(slug: params[:page])

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

  not_found do
    StatHat::API.ez_post_value("ERROR : NOT FOUND", ENV['STATHAT_EMAIL'], 1)
    flash.error = "Could not find #{request.fullpath}"
  end
end