class AssignmentsApp < Sinatra::Base
  register WillPaginate::Sinatra

  set :cache, Dalli::Client.new
  set :enable_cache, true
  set :views, Proc.new { File.join(root, "views") }
  set :erb, layout: :'../../views/layout'
  set :logging, true

  before do
    env['warden'].authenticate!
  end

  # index
  get '/?' do
    @sections = env['warden'].user.sections
    @assignments = @sections.assignments.published.all

    erb :index
  end

  # show
  get '/:year/:id/?' do
    @assignment = Assignment.get(params[:id])

    halt 404 if @assignment.nil? || @assignment.active == false

    require_admin if @assignment.draft == true

    erb :show
  end

  #############################################################################
  #
  # ADVISOR ROUTES
  #
  #############################################################################

  # edit
  get '/:year/:id/edit/?' do
    require_admin
    @sections = Section.all

    @assignment = Assignment.get(params[:id])

    halt 404 if @assignment.nil? || @assignment.active == false

    erb :edit
  end

  # new
  get '/new/?' do
    require_admin
    @assignment = Assignment.new
    @sections = Section.all

    halt 404 if @assignment.nil? || @assignment.active == false

    erb :new
  end

  # create
  post '/new' do
    require_admin

    params[:assignment][:user_id] = env['warden'].user.id

    @assignment = Assignment.create(params[:assignment])

    flash.success = "Assignment saved successfully."
    redirect "/assignments/#{@assignment.year}/#{@assignment.id}"
  end

  # update
  post '/:year/:id/update' do
    require_admin
    @assignment = Assignment.get(params[:id])

    if @assignment.update(params[:assignment])
      flash.success = "Assignment updated successfully"
      redirect "/assignments/#{@assignment.year}/#{@assignment.id}"
    else
      flash.error "We had a problem"
      redirect "/assignments/#{@assignment.year}/#{@assignment.id}/edit"
    end
  end

  # delete
  get '/:year/:id/delete' do
    require_admin
    @assignment = Assignment.get(params[:id])

    if @assignment.delete
      flash.success = "Assignment deleted"
      redirect "/assignments"
    else
      flash.error = "Assignment could not be deleted"
      redirect "/assignments/#{@assignment.year}/#{@assignment.id}"
    end
  end
end