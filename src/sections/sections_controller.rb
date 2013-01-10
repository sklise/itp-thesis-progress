class SectionsApp < Sinatra::Base
  # set :cache, Dalli::Client.new
  # set :enable_cache, true
  set :views, Proc.new { File.join(root, "views") }
  set :erb, layout: :'../../views/layout'

  get '/' do
    @sections = Section.all(year: 2013)
    erb :index
  end

  get '/new/?' do
    @advisors = User.advisors
    @section = Section.new
    erb :new
  end

  post '/new/?' do
    @section = Section.create(params[:section])
    section_user = SectionUser.create(section_id: @section.id, user_id: params[:advisor_id])
    # redirect "/sections/#{@section.year}/#{@section.slug}"
    "hi"
  end

  # show
  get '/:year/:slug/?' do
    @section = Section.first(
      year: params[:year],
      slug: params[:slug]
    )
    erb :show
  end

  # edit
  get '/:year/:slug/edit/?' do
    @section = Section.first(
      year: params[:year],
      slug: params[:slug],
    )
    erb :editd
  end

  # update
  post '/:year/:slug/update/?' do
    @section = Section.first(
      year: params[:year],
      name: params[:slug]
    )

    @section.update(
      name: params[:name]
    )

    redirect "/sections/#{@section.year}/#{@section.name}"
  end
end