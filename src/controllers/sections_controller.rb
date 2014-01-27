class SectionsApp < Sinatra::Base
  register WillPaginate::Sinatra
  register Sinatra::ThesisApp

  before do
    env['warden'].authenticate!
    @current_user = env['warden'].user
  end

  get '/?' do
    @sections = Section.current_year
    erb :'sections/index'
  end

  # show
  get '/:year/:slug/?' do
    @section = Section.first( year: params[:year], slug: params[:slug])

    if @section.nil?
      flash.error = "We couldn't find the section you were looking for."
      redirect "/sections"
    end

    erb :'sections/show'
  end

  get '/:year/:slug/comments/?' do
    @section = Section.first( year: params[:year], slug: params[:slug])

    if @section.nil?
      flash.error = "We couldn't find the section you were looking for."
      redirect "/sections"
    end

    @comments = @section.users.posts.comments.paginate(order: :created_at.desc, page: 1)

    erb :'sections/comments'
  end

  get '/:year/:slug/comments/page/:page_number/?' do
    @section = Section.first( year: params[:year], slug: params[:slug])

    if @section.nil?
      flash.error = "We couldn't find the section you were looking for."
      redirect "/sections"
    end

    @comments = @section.users.posts.comments.paginate(order: :created_at.desc, page: params[:page_number])

    erb :'sections/comments'
  end

  #############################################################################
  #
  # ADVISOR ROUTES
  #
  #############################################################################

  get '/new/?' do
    require_advisor

    @advisors = User.advisors
    @section = Section.new

    erb :'sections/new'
  end

  post '/new/?' do
    require_advisor

    @section = Section.create(params[:section])
    redirect @section.url
  end

  # edit
  get '/:year/:slug/edit/?' do
    require_advisor

    @section = Section.first(
      year: params[:year],
      slug: params[:slug],
    )

    erb :'sections/edit'
  end

  # update
  post '/:year/:slug/update/?' do
    require_advisor
    @section = Section.first(year: params[:year], slug: params[:slug])
    @section.update(name: params[:section][:name], slug: params[:section][:slug] )

    redirect @section.url
  end
end