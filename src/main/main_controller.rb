class Main < Sinatra::Base

  set :views, Proc.new { File.join(root, "views") }
  set :static, true
  set :public_folder, Proc.new { File.join(root, "../../public") }
  set :erb, layout: :'../../views/layout'

  before do
    env['warden'].authenticate!
  end

  get '/' do
    if env['warden'].authenticated?
      @announcements = Announcement.all(limit: 10, order: :published_at.desc)
      @recent_posts = Post.paginate(page:1, order: :published_at.desc)
      erb :dashboard
    else
      erb :front_page
    end
  end

  # If you're a teacher, links to your sections and a "blog feed" of recent
  # posts by your students.
  get '/dashboard' do
    @announcements = Announcement.all(limit: 10, order: :published_at.desc)
    @recent_posts = Post.paginate(page:1, order: :published_at.desc)

    # Student's section...schedule or such.

    erb :dashboard
  end

  get '/page/new' do
    @page = Page.new
    erb :'pages/new'
  end

  post '/page/new' do
    @page = Page.create(params[:page])
    redirect "/#{@page.slug}"
  end

  get '/:page' do
    @pages = Page.all
    pass if !@pages.slugs.include?(params[:page])
    @page = @pages.first(slug: params[:page])
    erb :'pages/show'
  end

  get '/:page/edit' do
    @pages = Page.all
    pass if !@pages.slugs.include?(params[:page])
    @page = @pages.first(slug: params[:page])
    erb :'pages/edit'
  end

  post '/:page' do
    @page = Page.update(params[:page])
    redirect "/#{@page.slug}"
  end

  post "/inspect" do
    raise params.inspect
  end

  not_found do
    flash.error = "Could not find #{request.fullpath}"
    redirect '/' # catch redirects to GET '/session'
  end
end