class SectionsApp < Sinatra::Base
  register WillPaginate::Sinatra

  set :cache, Dalli::Client.new
  set :enable_cache, true
  set :views, Proc.new { File.join(root, "views") }
  set :erb, layout: :'../../views/layout'
  set :logging, true

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
    require_advisor

    @advisors = User.advisors
    @section = Section.new

    erb :new
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

    erb :edit
  end

  # update
  post '/:year/:slug/update/?' do
    require_advisor
    @section = Section.first(year: params[:year], slug: params[:slug])
    @section.update(name: params[:section][:name], slug: params[:section][:slug] )

    redirect @section.url
  end

  not_found do
    flash.error = "Could not find #{request.fullpath}"
    redirect "/sections"
  end
end