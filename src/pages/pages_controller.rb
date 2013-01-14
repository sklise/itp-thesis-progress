class PagesApp < Sinatra::Base
  set :views, Proc.new { File.join(root, "views") }
  set :erb, layout: :'../../views/layout'

  before do
    env['warden'].authenticate!
  end

  get '/:page' do
    @pages = Page.all
    pass if !@pages.slugs.include?(params[:page])
    @page = @pages.first(slug: params[:page])
    erb :page
  end

  get '/page/new' do
    @page = Page.new
    erb :new
  end

  post '/page/new' do
    @page = Page.create(params[:page])
    redirect "/#{@page.slug}"
  end

  get '/:page/edit' do
    @pages = Page.all
    pass if !@pages.slugs.include?(params[:page])
    @page = @pages.first(slug: params[:page])
    erb :edit
  end

  post '/:page' do
    @page = Page.update(params[:page])
    redirect "/#{@page.slug}"
  end
end