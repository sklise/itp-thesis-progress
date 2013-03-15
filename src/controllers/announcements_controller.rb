class AnnouncementsApp < Sinatra::Base
  register WillPaginate::Sinatra
  register Sinatra::ThesisApp

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

    erb :'announcements/index'
  end

  get '/everyone/?' do
    @announcements = Announcement.published.paginate(page: 1, everyone: true)
    erb :'announcements/index'
  end

  get '/section/:year/:section_name/?' do
    @announcements = Section.first({
      slug: params[:section_name],
      year: params[:year]
    }).announcements.published.paginate(page: 1)
    erb :'announcements/index'
  end

  get '/section/:year/:section_name/page/:page_number/?' do
    @announcements = Section.first({
      slug: params[:section_name],
      year: params[:year]
    }).announcements.published.paginate(page: params[:page_number])
    erb :'announcements/index'
  end

  get '/page/:page_number/?' do
    @announcements = Announcement.published.paginate(page: params[:page_number])
    erb :'announcements/index'
  end

  get '/:year/:id/?' do
    @announcement = Announcement.published.first(id: params[:id])

    pass if @announcement.nil?

    erb :'announcements/show'
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
    erb :'announcements/new'
  end

  post '/' do
    require_admin
    content_type :json
    post_params = JSON.parse(request.body.read)

    post_params['user_id'] = env['warden'].user.id

    @announcement = Announcement.new(post_params)

    if @announcement.save
      @announcement.to_json
    else
      halt 500
    end
  end

  get '/:year/:id/delete' do
    require_admin

    Announcement.first(id: params[:id]).delete

    redirect "/announcements"
  end

  get '/:year/:id/edit/?' do
    redirect "/announcements/#{params[:id]}/edit"
  end

  get '/:id/edit' do
    require_admin
    @sections = Section.all
    @announcement = Announcement.get(params[:id])
    erb :'announcements/new'
  end

  put '/:id' do
    require_admin
    content_type :json
    post_params = JSON.parse(request.body.read)

    @announcement = Announcement.get(params[:id])

    @announcement.update post_params

    @announcement.to_json
  end
end