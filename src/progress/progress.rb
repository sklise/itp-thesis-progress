require 'redcarpet'

class ProgressApp < Sinatra::Base
  register WillPaginate::Sinatra
  register Sinatra::Warden

  set :views, Proc.new { File.join(root, "views") }
  set :erb, layout: :'../../views/layout'

  get '/' do
    @posts = Post.paginate(page: 1, order: :created_at.desc)
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
    @post = Post.new(params[:post])
    if @post.save
      puts "save"
      redirect "/progress"
    else
      # flash message
      redirect "/progress/new"
    end
  end

  get '/:year/:month/:date/:title/?' do
    date = Date.parse("#{params[:year]}/#{params[:month]}/#{params[:date]}")
    @post = Post.first(title: params[:title], created_at: (date..(date+1)))
    erb :show
  end

  get '/:year/:month/:date/:title/:edit/?' do
    date = Date.parse("#{params[:year]}/#{params[:month]}/#{params[:date]}")
    @post = Post.first(title: params[:title], created_at: (date..(date+1)))
    erb :edit
  end

  post '/:year/:month/:date/:title/update' do
    date = Date.parse("#{params[:year]}/#{params[:month]}/#{params[:date]}")
    @post = Post.first(title: params[:title], created_at: (date..(date+1)))

    @post.update(params[:post])

    if @post.save
      "oyez"
    else
      "onoz"
    end
  end

end