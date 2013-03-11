class Main < ThesisBaseApp
  register WillPaginate::Sinatra

  set :views, Proc.new { File.join(root, "views") }
  set :static, true
  set :public_folder, Proc.new { File.join(root, "../../public") }
  set :erb, layout: :'../../views/layout'

  before do
    env['warden'].authenticate!
    @current_user = env['warden'].user
  end

  get '/' do
    env['warden'].authenticate!
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

  unless ENV['RACK_ENV'] == 'production'
    get '/set_user/:netid' do
      if @current_user.netid == "sk3453"
        @user = User.first netid: params[:netid]
        env['warden'].set_user @user
        @user.to_json
      else
        "sorry"
      end
    end
  end
end