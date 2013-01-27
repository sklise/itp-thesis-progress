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

  get '/' do
    @posts = Post.paginate(page: 1, order: :created_at.desc)
    erb :index
  end

  get '/page/:page_number/?' do
    @posts = Post.paginate(page: params[:page_number], order: :created_at.desc)
    erb :index
  end

  #############################################################################
  #
  # PROFILE PAGE
  #
  #############################################################################

  get '/:netid/?' do
    @user = User.first(netid: params[:netid])
    @categories = Category.all
    erb :profile
  end

  #############################################################################
  #
  # THESIS PAGE
  #
  #############################################################################

  get '/:netid/thesis/?' do
    @user = User.first(netid: params[:netid])
    @thesis = Thesis.first(user: @user)
    erb :thesis
  end

  get '/:netid/thesis/edit' do
    check_user(params[:netid])
    @thesis = Thesis.first(:user => env['warden'].user)
    erb :thesis_edit
  end

  post '/:netid/thesis/update' do
    check_user(params[:netid])
    content_type :json
    @thesis = Thesis.first(:user => env['warden'].user)

    # Notify advisor!

    if @thesis.update(params[:thesis])
      flash.success = "Thesis updated, please tell your advisor."
      redirect '/thesis'
    else
      flash.error = "There was an error updating your thesis."
      redirect '/thesis/edit'
    end
  end

  #############################################################################
  #
  # PROGRESS BLOGS
  #
  #############################################################################

  get '/:netid/progress/?' do
    @user = User.first(netid:params[:netid])
    @posts = Post.paginate(page: 1, order: :created_at.desc, user: @user)
    erb :index
  end

  get '/:netid/progress/page/:page_number/?' do
    @user = User.first(netid:params[:netid])
    @posts = Post.paginate(page: params[:page_number], order: :created_at.desc, user: @user)
    erb :index
  end

  get '/:netid/:id/:slug/?' do
    @post = Post.get(params[:id])

    if @post.draft || @post.nil?
      flash.error = "Sorry, that post is not viewable."
      redirect "/"
    else
      erb :'show'
    end
  end

  get '/:netid/:id/:slug/:edit/?' do
    check_user(params[:netid])
    @categories = Category.all
    @post = Post.first(id: params[:id])
    erb :edit
  end

  post '/:netid/:id/:slug/update' do
    check_user(params[:netid])
    @post = Post.first(id: params[:id])

    @post.update(params[:post])

    if @post.save
      flash.success = "Post updated successfully"
      redirect @post.url
    else
      flash.error = "We had a problem updating your post..."
      redirect "#{@post.url}/edit"
    end
  end

  get '/:netid/:id/:slug/delete' do
    check_user(params[:netid])
    Post.first(id: params[:id]).destroy

    redirect "/students/#{params[:netid]}/progress"
  end

  get '/new' do
    @assignment = Assignment.get(params[:assignment_id])
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
      redirect "/students/#{env['warden'].user.netid}"
    else
      flash.error = "There was an issue creating that post"
      redirect "/students/new"
    end
  end

end