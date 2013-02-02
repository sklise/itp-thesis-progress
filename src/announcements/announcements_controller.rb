class AnnouncementsApp < Sinatra::Base
  register WillPaginate::Sinatra

  set :logging, true
  set :cache, Dalli::Client.new
  set :enable_cache, true
  set :views, Proc.new { File.join(root, "views") }
  set :erb, layout: :'../../views/layout'

  before do
    env['warden'].authenticate!
  end

  get '/' do
    @announcements = Announcement.published.paginate(page: 1)
    erb :index
  end

  get '/everyone/?' do
    @announcements = Announcement.published.paginate(page: 1, everyone: true)
    erb :index
  end

  get '/section/:year/:section_name/?' do
    @announcements = Section.first({
      slug: params[:section_name],
      year: params[:year]
    }).announcements.published.paginate(page: 1)
    erb :index
  end

  get '/section/:year/:section_name/page/:page_number/?' do
    @announcements = Section.first({
      slug: params[:section_name],
      year: params[:year]
    }).announcements.published.paginate(page: params[:page_number])
    erb :index
  end

  get '/page/:page_number/?' do
    @announcements = Announcement.published.paginate(page: params[:page_number])
    erb :index
  end

  get '/:year/:id/?' do
    @announcement = Announcement.published.first(id: params[:id])

    halt 404 if @announcement.nil?

    erb :show
  end

  #############################################################################
  #
  # ADVISOR ROUTES
  #
  #############################################################################

  get '/new/?' do
    require_admin

    @sections = Section.all
    @announcement = Announcement.new
    erb :new
  end

  post '/new/?' do
    require_admin

    @announcement = Announcement.create(params[:announcement])
    redirect @announcement.url
  end

  get '/:year/:id/delete' do
    require_admin

    Announcement.first(id: params[:id]).delete

    redirect "/announcements"
  end

  get '/:year/:id/edit/?' do
    require_admin

    @sections = Section.all
    @announcement = Announcement.published.first(id: params[:id])

    halt 404 if @announcement.nil?

    erb :edit
  end

  post '/:year/:id/?' do
    require_admin

    @announcement = Announcement.published.first(id: params[:id])

    halt 404 if @announcement.nil?

    @announcement.update(params[:announcement])
    flash.success = "Announcement Updated Successfully."
    redirect @announcement.url
  end

  not_found do
    flash.error = "Could not find #{request.fullpath}"
    redirect "/announcements"
  end
end