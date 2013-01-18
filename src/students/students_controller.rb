class StudentsApp < Sinatra::Base
  register WillPaginate::Sinatra

  set :cache, Dalli::Client.new
  set :enable_cache, true
  set :logging, true
  set :views, Proc.new { File.join(root, "views") }
  set :erb, layout: :'../../views/layout'

  before do
    env['warden'].authenticate!
  end

  get '/:netid/:id/:slug' do
    @post = Post.get(params[:id])
    if @post.draft || @post.nil?
      flash.error = "Sorry, that post is not viewable."
      redirect "/"
    else
      erb :'../../progress/views/show'
    end
  end

end