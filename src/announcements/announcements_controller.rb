class AnnouncementsApp < ThesisBaseApp
  set :views, Proc.new { File.join(File.dirname(__FILE__), "views") }
  set :erb, layout: :"../../views/layout"

  register WillPaginate::Sinatra

  before do
    env['warden'].authenticate!
    @current_user = env['warden'].user

    if @current_user.provisional?
      flash.error = "You are not authorized to view that page."
      redirect "/"
    end
  end

  get '/' do
    @announcements = Announcement.published.paginate(page: 1)

    @drafts = @current_user.announcements.drafts if @current_user.advisor?

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
end