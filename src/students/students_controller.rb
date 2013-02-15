require 'uri'

class StudentsApp < Sinatra::Base
  register WillPaginate::Sinatra

  set :cache, Dalli::Client.new
  set :enable_cache, true
  set :logging, true
  set :views, Proc.new { File.join(root, "views") }
  set :erb, layout: :'../../views/layout'

  def authenticate
    env['warden'].authenticate!
    @current_user = env['warden'].user
  end

  get '/' do
    authenticate
    @posts = Post.published.paginate(page: 1)
    erb :index
  end

  get '/page/:page_number/?' do
    authenticate
    @posts = Post.published.paginate(page: params[:page_number])
    erb :index
  end

  #############################################################################
  #
  # PROGRESS BLOGS
  #
  #############################################################################

  get '/:netid/progress/?' do
    authenticate
    @user = User.first netid: params[:netid]

    halt 404 if @user.nil?

    if @user == @current_user
      @drafts = @user.posts.drafts
    end

    @posts = Post.published.paginate(page: 1, user: @user)
    erb :'progress_index'
  end

  get '/:netid/progress/page/:page_number/?' do
    authenticate
    @user = User.first netid: params[:netid]

    halt 404 if @user.nil?

    @posts = Post.published.paginate(page: params[:page_number], user: @user)
    erb :'progress_index'
  end

  get '/:netid/progress/:category?' do
    authenticate
    @user = User.first netid: params[:netid]
    @category = Category.first slug: params[:category]

    # Stop here if no user was found with a matching netid.
    halt 404 if @user.nil?

    @posts = Post.published.paginate(page: 1, user: @user, category_id: @category.id)

    erb :'progress_index'
  end

  get '/:netid/progress/:category/page/:page_number/?' do
    authenticate
    @user = User.first netid: params[:netid]
    @category = Category.first slug: params[:category]

    # Stop here if no user was found with a matching netid.
    halt 404 if @user.nil?

    @posts = Post.published.paginate(page: params[:page_number], user: @user, category_id: @category.id)

    erb :'progress_index'
  end

  #############################################################################
  #
  # THESIS PAGE
  #
  #############################################################################

  get '/:netid/thesis/?' do
    authenticate
    @user = User.first(netid: params[:netid])
    @thesis = @user.theses.last

    if @current_user.non_student?
      @feedback = @user.received_feedbacks.all(active: true)
    end

    erb :thesis
  end

  get '/:netid/thesis/edit' do
    authenticate
    check_user(params[:netid])

    @site_config = SiteConfig.first
    if @site_config.thesis_lock
      flash.error = "Edits to thesis summaries are currently locked for review."
      redirect "/students/#{params[:netid]}/thesis"
    end

    @user = User.first(netid: params[:netid])

    @thesis = @user.theses.last
    erb :thesis_edit
  end

  post '/:netid/thesis/update' do
    authenticate
    check_user(params[:netid])
    content_type :json

    @site_config = SiteConfig.first
    if @site_config.thesis_lock
      flash.error = "Edits to thesis summaries are currently locked for review."
      redirect "/students/#{params[:netid]}/thesis"
    end

    @user = User.first netid: params[:netid]

    old_thesis = @user.theses.last
    params[:thesis][:id] = nil
    params[:thesis][:created_at] = nil
    new_thesis = Thesis.new(old_thesis.attributes.merge(params[:thesis]))

    if params[:image]
      image_path = "#{@user.netid}-#{Time.now.to_i}/#{URI.escape(params[:image][:filename].gsub(" ","_"))}"

      AWS::S3::Base.establish_connection!(:access_key_id => ENV['S3_ACCESS_KEY'], :secret_access_key => ENV['S3_SECRET_KEY'])
      AWS::S3::S3Object.store(image_path, open(params[:image][:tempfile]), "itp-thesis", access: :public_read)
       new_thesis.image = "http://itp-thesis.s3.amazonaws.com/" + image_path
    end

    @user.theses << new_thesis

    if @user.save
      flash.success = "Thesis summary."
      redirect "#{@user.url}/thesis"
    else
      flash.error = "There was an error updating your thesis."
      redirect "#{@user.url}/thesis/edit"
    end
  end

  #############################################################################
  #
  # POSTS
  #
  #############################################################################
  get '/:netid/comments/?' do
    authenticate
    @user = User.first(netid:params[:netid])

    halt 404 if @user.nil?

    @comments_by = Comment.all(user: @user, order: :created_at.desc)
    @comments_to = @user.posts.comments.all(order: :created_at.desc)
    erb :'comments'
  end

  get '/:netid/:id/:slug/?' do
    # Get the post with only the necessary fields.
    @post = Post.first(id: params[:id], active: true)

    # Redirect if the post is a draft
    if (@post.draft && @post.user.id != @current_user.id ) || @post.nil?
      flash.error = "Sorry, that post is not viewable."
      redirect "/"
    elsif !@post.is_public && !env['warden'].authenticated?
      env['warden'].authenticate!
    else
      @current_user = env['warden'].user
      erb :'progress_show'
    end
  end

  get '/:netid/:id/:slug/edit/?' do
    authenticate
    check_user(params[:netid])

    @categories = Category.all
    @post = Post.first(id: params[:id])

    erb :'progress_edit'
  end

  post '/:netid/:id/:slug/update' do
    authenticate
    check_user(params[:netid])

    @post = Post.first(id: params[:id])

    @post.title = params[:post][:title]
    @post.content = params[:post][:content]
    @post.category_id = params[:post][:category_id]
    @post.draft = params[:post][:draft]
    @post.is_public = params[:post][:is_public]

    if @post.save
      flash.success = "Post updated successfully"
      redirect @post.url
    else
      flash.error = "We had a problem updating your post..."
      redirect "#{@post.url}/edit"
    end
  end

  get '/:netid/:id/:slug/delete' do
    authenticate
    check_user(params[:netid])

    Post.first(id: params[:id]).delete

    redirect "/students/#{params[:netid]}/progress"
  end

  get '/new' do
    authenticate
    @assignment = Assignment.get(params[:assignment_id])
    @categories = Category.all
    @post = Post.new
    erb :'progress_new'
  end

  post '/new' do
    authenticate
    @post = Post.new(params[:post])

    @post.user = @current_user

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
    authenticate
    @user = User.first(netid: params[:netid])
    @categories = Category.all
    # erb :profile
    if @current_user.faculty?
      redirect "/students/#{params[:netid]}/thesis"
    else
      redirect "/students/#{params[:netid]}/progress"
    end
  end

end