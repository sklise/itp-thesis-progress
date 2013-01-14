class AnnouncementsApp < Sinatra::Base
  register WillPaginate::Sinatra

  set :views, Proc.new { File.join(root, "views") }
  set :erb, layout: :'../../views/layout'

  before do
    env['warden'].authenticate!
  end

  get '/' do
    @announcements = Announcement.paginate(page: 1, order: :published_at.desc)
    erb :index
  end

  get '/section/:section_name/' do
    @announcements = Announcement.paginate(page: 1, order: :published_at.desc)
    erb :index
  end

  get '/section/:section_name/page/:page_number' do
    @announcements = Announcement.paginate(page: params[:page_number], order: :published_at.desc)
    erb :index
  end

  get '/page/:page_number' do
    @announcements = Announcement.paginate(page: params[:page_number], order: :published_at.desc)
    erb :index
  end

  get '/:year/:issue' do
    @announcement = Announcement.first(year: params[:year], issue: params[:issue])

    halt 404 if @announcement.nil?

    erb :show
  end

  # FACULTY ONLY ROUTES
  get '/new' do
    @sections = Section.all
    @announcement = Announcement.new
    erb :new
  end

  post '/new' do
    @announcement = Announcement.create(params[:announcement])

    redirect "/announcements/#{@announcement.year}/#{@announcement.issue}"
  end

  get '/:year/:issue/edit' do
    @sections = Section.all
    @announcement = Announcement.first(year: params[:year], issue: params[:issue])

    halt 404 if @announcement.nil?

    erb :edit
  end

  post '/:year/:issue' do
    @announcement = Announcement.first(year: params[:year], issue: params[:issue])

    halt 404 if @announcement.nil?

    @announcement.update(params[:announcement])
    flash.success = "Announcement Updated Successfully."
    redirect "/announcements/#{params[:year]}/#{params[:issue]}"
  end
end