class ProgressApp < Sinatra::Base
  register WillPaginate::Sinatra

  set :views, Proc.new { File.join(root, "views") }
  set :erb, layout: :'../../views/layout'

  before do
    env['warden'].authenticate!
  end

  get '/' do
    @posts = Post.paginate(page: 1, order: :created_at.desc, user: env['warden'].user)
    erb :index
  end

  get '/page/:page_number' do
    @posts = Post.paginate(page: params[:page_number], order: :created_at.desc)
    erb :index
  end

  get '/new' do
    @categories = Category.all
    @post = Post.new
    erb :new_post
  end

  post '/new' do
    if params[:quickpost]
      @post = Post.quick_new(params)
    else
      @post = Post.new(params[:post])
    end

    @post.user = env['warden'].user

    if @post.save
      flash.success = "Post Saved"
      redirect "/progress"
    else
      flash.error = "There was an issue creating that post"
      redirect "/progress/new"
    end
  end

  get '/:year/:month/:date/:title/?' do
    date = Date.parse("#{params[:year]}/#{params[:month]}/#{params[:date]}")
    @post = Post.first(title: params[:title], created_at: (date..(date+1)))
    erb :show
  end

  get '/:year/:month/:date/:title/:edit/?' do
    @categories = Category.all
    date = Date.parse("#{params[:year]}/#{params[:month]}/#{params[:date]}")
    @post = Post.first(title: params[:title], created_at: (date..(date+1)))
    erb :edit
  end

  post '/:year/:month/:date/:title/update' do
    date = Date.parse("#{params[:year]}/#{params[:month]}/#{params[:date]}")
    @post = Post.first(title: params[:title], created_at: (date..(date+1)))

    @post.update(params[:post])

    if @post.save
      flash.success = "Post updated successfully"
      redirect @post.url
    else
      flash.error = "We had a problem updating your post..."
      redirect "#{@post.url}/edit"
    end
  end

end