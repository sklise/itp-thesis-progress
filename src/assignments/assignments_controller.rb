class AssignmentsApp < Sinatra::Base
  register WillPaginate::Sinatra
  register Sinatra::ThesisApp

  before do
    env['warden'].authenticate!
    @current_user = env['warden'].user
  end

  # index
  get '/?' do
    @sections = @current_user.sections

    if @sections
      @assignments = @sections.assignments.published.all
    else
      @assignments = Assignment.published.all
    end

    erb :'assignments/index'
  end

  # show
  get '/:year/:id/?' do
    @assignment = Assignment.get(params[:id])

    halt 404 if @assignment.nil? || @assignment.active == false

    require_advisor if @assignment.draft == true

    erb :'assignments/show'
  end

  #############################################################################
  #
  # ADVISOR ROUTES
  #
  #############################################################################

  # edit
  get '/:year/:id/edit/?' do
    require_advisor
    @sections = Section.all

    @assignment = Assignment.get(params[:id])

    halt 404 if @assignment.nil? || @assignment.active == false

    erb :'assignments/edit'
  end

  # new
  get '/new/?' do
    require_advisor
    @assignment = Assignment.new
    @sections = Section.all

    halt 404 if @assignment.nil? || @assignment.active == false

    erb :'assignments/new'
  end

  # create
  post '/new' do
    require_advisor

    params[:assignment][:user_id] = @current_user.id

    @assignment = Assignment.create(params[:assignment])

    flash.success = "Assignment saved successfully."
    redirect "/assignments/#{@assignment.year}/#{@assignment.id}"
  end

  # update
  post '/:year/:id/update' do
    require_advisor
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
    require_advisor
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