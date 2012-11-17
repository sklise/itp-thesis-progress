class AssignmentsApp < Sinatra::Base
  set :views, Proc.new { File.join(root, "views") }
  set :erb, layout: :'../../views/layout'

  # index
  get '/' do
    erb :index
  end

  # new
  get '/new' do
    @assignment = Assignment.new
    @sections = Section.all

    erb :new
  end

  # create
  post '/new' do
    raise params[:assignment].inspect
    @assignment = Assignment.new(params[:assignment])

    if @assignment.save
      flash.success = "Assignment saved successfully."
      redirect "/assignments"
    else
      flash.error = "We've encountered a problem."
      redirect "/assignments/new"
    end
  end

  # show
  get '/:year/:id' do
    @assignment = Assignment.first(params[:id])
    erb :show
  end

  # edit
  get '/:year/:id/edit' do
    @assignment = Assignment.first(params[:id])
    erb :edit
  end

  # update
  post '/:year/:id/update' do
    @assignment = Assignment.first(params[:id])

    if @assignment.update(params[:assignment])
      flash.success = "Assignment updated successfully"
      redirect "/assignments/#{@assignment.year}/#{@assignment.id}"
    else
      flash.error "We had a problem"
      redirect "/assignments/#{@assignment.year}/#{@assignment.id}/edit"
    end
  end

  # delete
  post '/:year/:id/destroy' do
    @assignment = Assignment.first(params[:id])

    if @assignment.destroy
      flash.success = "Assignment destroyed"
      redirect "/assignments"
    else
      flash.error = "Assignment could not be destroyed"
      redirect "/assignments/#{@assignment.year}/#{@assignment.id}"
    end
  end
end