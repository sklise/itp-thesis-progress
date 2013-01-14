class Main < Sinatra::Base

  set :views, Proc.new { File.join(root, "views") }
  set :static, true
  set :public_folder, Proc.new { File.join(root, "../../public") }
  set :erb, layout: :'../../views/layout'

  before do
    env['warden'].authenticate!
  end

  get '/' do
    erb :front_page
  end

  # If you're a teacher, links to your sections and a "blog feed" of recent
  # posts by your students.
  get '/dashboard' do
    @announcements = Announcement.all(limit: 10, order: :published_at.desc)
    @recent_posts = Post.paginate(page:1, order: :published_at.desc)

    # Student's section...schedule or such.

    erb :dashboard
  end

  post "/inspect" do
    raise params.inspect
  end

  not_found do
    flash.error = "Could not find #{request.fullpath}"
    redirect '/' # catch redirects to GET '/session'
  end
end