class AnnouncementsApp < Sinatra::Base
  register WillPaginate::Sinatra

  set :logging, true
  set :cache, Dalli::Client.new
  set :enable_cache, true
  set :views, Proc.new { File.join(root, "views") }
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
    require_non_student

    @sections = Section.all
    @announcement = Announcement.new
    erb :new
  end

  post '/new/?' do
    require_non_student

    @announcement = Announcement.create(params[:announcement])

    if params[:send_email] && !@announcement.draft
      @announcement.send_email
    end

    redirect @announcement.url
  end

  get '/:year/:id/delete' do
    require_non_student

    Announcement.first(id: params[:id]).delete

    redirect "/announcements"
  end

  get '/:year/:id/edit/?' do
    require_non_student

    @sections = Section.all
    @announcement = Announcement.published.first(id: params[:id])

    halt 404 if @announcement.nil?

    erb :edit
  end

  post '/:year/:id/?' do
    require_non_student

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