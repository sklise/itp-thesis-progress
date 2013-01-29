require 'uri'

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
    @posts = Post.paginate(page: 1, order: :published_at.desc, draft: false)
    erb :index
  end

  get '/page/:page_number/?' do
    @posts = Post.paginate(page: params[:page_number], order: :published_at.desc, draft: false)
    erb :index
  end

  #############################################################################
  #
  # PROGRESS BLOGS
  #
  #############################################################################

  get '/:netid/progress/?' do
    @user = User.first(netid:params[:netid])

    if @user == env['warden'].user
      @drafts = @user.posts.all(draft: true, order: :updated_at.desc)
    end

    @posts = Post.paginate(page: 1, order: :published_at.desc, user: @user, draft: false)
    erb :'progress_index'
  end

  get '/:netid/progress/page/:page_number/?' do
    @user = User.first(netid:params[:netid])

    if @user == env['warden'].user
      @drafts = @user.posts.all(draft: true, order: :updated_at.desc)
    end

    @posts = Post.paginate(page: params[:page_number], order: :published_at.desc, user: @user, draft: false)
    erb :'progress_index'
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
    @user = @thesis.user

    if params[:image]
      image_path = "#{@user.netid}-#{Time.now.to_i}/#{URI.escape(params[:image][:filename].gsub(" ","_"))}"

      AWS::S3::Base.establish_connection!(:access_key_id => ENV['S3_ACCESS_KEY'], :secret_access_key => ENV['S3_SECRET_KEY'])
      AWS::S3::S3Object.store(image_path, open(params[:image][:tempfile]), "itp-thesis", access: :public_read)
      params[:thesis][:image] = "http://itp-thesis.s3.amazonaws.com/" + image_path
    end

    if @thesis.update(params[:thesis])
      flash.success = "Thesis summary."
      redirect "#{@thesis.user.url}/thesis"
    else
      flash.error = "There was an error updating your thesis."
      redirect "#{@thesis.user.url}/thesis/edit"
    end
  end

  #############################################################################
  #
  # POSTS
  #
  #############################################################################


  get '/:netid/:id/:slug/?' do
    @post = Post.get(params[:id])

    if @post.draft || @post.nil?
      flash.error = "Sorry, that post is not viewable."
      redirect "/"
    else
      erb :'progress_show'
    end
  end

  get '/:netid/:id/:slug/:edit/?' do
    check_user(params[:netid])

    @categories = Category.all
    @post = Post.first(id: params[:id])
    erb :'progress_edit'
  end

  post '/:netid/:id/:slug/update' do
    check_user(params[:netid])
    @post = Post.first(id: params[:id])

    @post.title = params[:post][:title]
    @post.content = params[:post][:content]
    @post.category_id = params[:post][:category_id]
    @post.draft = params[:post][:draft]

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
    erb :'progress_new'
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
      redirect "#{@post.url}"
    else
      raise @post.inspect
      flash.error = "There was an issue creating that post"
      redirect "/students/new"
    end
  end


  #############################################################################
  #
  # PROFILE PAGE
  #
  #############################################################################

  get '/:netid/?' do
    @user = User.first(netid: params[:netid])
    @categories = Category.all
    # erb :profile
    redirect "/students/#{params[:netid]}/progress"
  end

end