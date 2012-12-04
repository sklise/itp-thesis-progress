class Main < Sinatra::Base

  set :views, Proc.new { File.join(root, "views") }
  set :static, true
  set :public_folder, Proc.new { File.join(root, "../../public") }
  set :erb, layout: :'../../views/layout'

  before do
    redirect '/applications'
  end

  get '/' do
    erb :front_page
  end

  # If you're a teacher, links to your sections and a "blog feed" of recent
  # posts by your students.
  get '/dashboard' do

  end

  get '/students/:name' do

  end

  # Big 'ol list of everyone from that year and links to the sections
  get '/years/:year' do

  end

  # Year listed by section
  get '/years/:year/sections' do

  end

  # An individual section
  get '/years/:year/sections/:section' do

  end

  post "/inspect" do
    raise params.inspect
  end

  not_found do
    flash.error = "Could not find #{request.fullpath}"
    redirect '/' # catch redirects to GET '/session'
  end
end