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
      @announcements = Announcement.all(limit: 10, order: :published_at.desc)
      @recent_posts = Post.paginate(page:1, order: :published_at.desc)
      erb :dashboard
    else
      erb :front_page
    end
  end

  get '/class' do
    if env['warden'].user.advisor?
      @sections = env['warden'].user.sections

      student_ids = []
      @sections.each do |section|
        section.students.each do |student|
          student_ids.push student.id
        end
      end
      @students = User.all(:id => student_ids)
      puts @students.length
      erb :'section/advisor'
    else
      @section = env['warden'].user.sections[0]
      erb :'section/student'
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
    unless env['warden'].user.advisor?
      flash.error = "You are not authorized to access that page."
      redirect '/'
    end
    @page = Page.new
    erb :'pages/new'
  end

  post '/page/new' do
    unless env['warden'].user.advisor?
      flash.error = "You are not authorized to access that page."
      redirect '/'
    end
    @page = Page.create(params[:page])
    redirect "/#{@page.slug}"
  end

  get '/:page/edit' do
    unless env['warden'].user.advisor?
      flash.error = "You are not authorized to access that page."
      redirect '/'
    end
    @pages = Page.all
    pass if !@pages.slugs.include?(params[:page])
    @page = @pages.first(slug: params[:page])
    erb :'pages/edit'
  end

  post '/:page' do
    unless env['warden'].user.advisor?
      flash.error = "You are not authorized to access that page."
      redirect '/'
    end
    @page = Page.update(params[:page])
    redirect "/#{@page.slug}"
  end

  not_found do
    flash.error = "Could not find #{request.fullpath}"
    redirect '/' # catch redirects to GET '/session'
  end
end