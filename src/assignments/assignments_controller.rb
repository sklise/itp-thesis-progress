class AssignmentsApp < Sinatra::Base
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

  # index
  get '/?' do
    @sections = @current_user.sections

    if @sections
      @assignments = @sections.assignments.published.all
    else
      @assignments = Assignment.published.all
    end

    erb :index
  end

  # show
  get '/:year/:id/?' do
    @assignment = Assignment.get(params[:id])

    halt 404 if @assignment.nil? || @assignment.active == false

    require_advisor if @assignment.draft == true

    erb :show
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

    erb :edit
  end

  # new
  get '/new/?' do
    require_advisor
    @assignment = Assignment.new
    @sections = Section.all

    halt 404 if @assignment.nil? || @assignment.active == false

    erb :new
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