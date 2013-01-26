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
    @announcements = Announcement.paginate(page: 1, order: :published_at.desc)
    erb :index
  end

  get '/everyone/?' do
    @announcements = Announcement.paginate(page: 1, order: :published_at.desc, everyone: true)
    erb :index
  end

  get '/section/:year/:section_name/?' do
    @announcements = Section.first({
      slug: params[:section_name],
      year: params[:year]
    }).announcements.paginate(page: 1, order: :published_at.desc)
    erb :index
  end

  get '/section/:year/:section_name/page/:page_number/?' do
    @announcements = Section.first({
      slug: params[:section_name],
      year: params[:year]
    }).announcements.paginate(page: params[:page_number], order: :published_at.desc)
    erb :index
  end

  get '/page/:page_number/?' do
    @announcements = Announcement.paginate(page: params[:page_number], order: :published_at.desc)
    erb :index
  end

  get '/:year/:issue/?' do
    @announcement = Announcement.first(year: params[:year], issue: params[:issue])

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
    redirect "/announcements/#{@announcement.year}/#{@announcement.issue}"
  end

  get '/:year/:issue/delete' do
    require_admin

    Announcement.first(year: params[:year], issue: params[:issue]).destroy

    redirect "/announcements"
  end

  get '/:year/:issue/edit/?' do
    require_admin

    @sections = Section.all
    @announcement = Announcement.first(year: params[:year], issue: params[:issue])

    halt 404 if @announcement.nil?

    erb :edit
  end

  post '/:year/:issue/?' do
    require_admin

    @announcement = Announcement.first(year: params[:year], issue: params[:issue])

    halt 404 if @announcement.nil?

    @announcement.update(params[:announcement])
    flash.success = "Announcement Updated Successfully."
    redirect "/announcements/#{params[:year]}/#{params[:issue]}"
  end

  not_found do
    flash.error = "Could not find #{request.fullpath}"
    redirect "/announcements"
  end
end