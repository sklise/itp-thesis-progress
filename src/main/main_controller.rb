class Main < Sinatra::Base
  register WillPaginate::Sinatra

  set :views, Proc.new { File.join(root, "views") }
  set :static, true
  set :logging, true
  set :cache, Dalli::Client.new
  set :enable_cache, true
  set :public_folder, Proc.new { File.join(root, "../../public") }
  set :erb, layout: :'../../views/layout'

  before do
    env['warden'].authenticate!
  end

  get '/' do
    if env['warden'].authenticated?
      @user = env['warden'].user

      if @user.student?
        @drafts = @user.posts.drafts
        @assignments = @user.sections.assignments.published.all
        @comments = @user.posts.comments.all(order: :created_at.desc, limit: 10)
        @announcements = Announcement.published.all(limit: 10)

        @recent_posts = @user.sections.first.students.posts.published.paginate(page: 1)
        erb :'dashboards/student'
      else
        # @announcement_drafts = @user.announcements.drafts
        @announcements = Announcement.published.all(limit: 10)
        @sections = env['warden'].user.sections
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
    erb :'pages/edit'
  end

  post '/:page' do
    require_admin
    @page = Page.first(slug: params[:page])
    @page.update(params[:page_form])
    redirect "/#{@page.slug}"
  end

  not_found do
    flash.error = "Could not find #{request.fullpath}"
  end
end