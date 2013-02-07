class SectionsApp < Sinatra::Base
  register WillPaginate::Sinatra

  set :cache, Dalli::Client.new
  set :enable_cache, true
  set :views, Proc.new { File.join(root, "views") }
  set :erb, layout: :'../../views/layout'
  set :logging, true

  before do
    env['warden'].authenticate!
    @current_user = env['warden'].user
  end

  get '/?' do
    @sections = Section.all(year: 2013)
    erb :index
  end

  # show
  get '/:year/:slug/?' do
    @section = Section.first( year: params[:year], slug: params[:slug])

    if @section.nil?
      flash.error = "We couldn't find the section you were looking for."
      redirect "/sections"
    end

    erb :show
  end

  get '/:year/:slug/comments/?' do
    @section = Section.first( year: params[:year], slug: params[:slug])

    if @section.nil?
      flash.error = "We couldn't find the section you were looking for."
      redirect "/sections"
    end

    @comments = @section.users.posts.comments.paginate(order: :created_at.desc, page: 1)

    erb :comments
  end

  get '/:year/:slug/comments/page/:page_number/?' do
    @section = Section.first( year: params[:year], slug: params[:slug])

    if @section.nil?
      flash.error = "We couldn't find the section you were looking for."
      redirect "/sections"
    end

    @comments = @section.users.posts.comments.paginate(order: :created_at.desc, page: params[:page_number])

    erb :comments
  end

  #############################################################################
  #
  # ADVISOR ROUTES
  #
  #############################################################################

  get '/new/?' do
    require_admin

    @advisors = User.advisors
    @section = Section.new

    erb :new
  end

  post '/new/?' do
    require_admin

    @section = Section.create(params[:section])
    redirect @section.url
  end

  # edit
  get '/:year/:slug/edit/?' do
    require_admin

    @section = Section.first(
      year: params[:year],
      slug: params[:slug],
    )

    erb :edit
  end

  # update
  post '/:year/:slug/update/?' do
    require_admin
    @section = Section.first(year: params[:year], slug: params[:slug])
    @section.update(name: params[:section][:name], slug: params[:section][:slug] )

    redirect @section.url
  end

  not_found do
    flash.error = "Could not find #{request.fullpath}"
    redirect "/sections"
  end
end