class SectionsApp < Sinatra::Base
  register WillPaginate::Sinatra

  # set :cache, Dalli::Client.new
  # set :enable_cache, true
  set :views, Proc.new { File.join(root, "views") }
  set :erb, layout: :'../../views/layout'

  get '/' do
    @sections = Section.all(year: 2013)
    erb :index
  end

  # show
  get '/:year/:slug/?' do
    @section = Section.first(
      year: params[:year],
      slug: params[:slug]
    )
    erb :show
  end

  # INDIVIDUAL STUDENT
  get '/:year/:slug/:netid' do
    @section = Section.first(year: params[:year], slug: params[:slug])
    @student = User.first(netid: params[:netid])
    @posts = @student.posts.paginate(page: 1, order: :published_at.desc)
    erb :student
  end

  # ADVISOR ROUTES

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