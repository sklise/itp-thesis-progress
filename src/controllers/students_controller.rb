class StudentsApp < Sinatra::Base
  register WillPaginate::Sinatra
  register Sinatra::ThesisApp

  def authenticate
    env['warden'].authenticate!
    @current_user = env['warden'].user
  end

  get '/' do
    authenticate

    @posts = Post.published.paginate(page: 1)
    @drafts = Post.drafts.all(user_id: @current_user.id)
    StatHat::API.ez_post_value("Students : All : 1", ENV['STATHAT_EMAIL'], 1)
    erb :'students/index'
  end

  get '/page/:page_number/?' do
    authenticate
    @posts = Post.published.paginate(page: params[:page_number])
    StatHat::API.ez_post_value("Students : All : #{params[:page_number]}", ENV['STATHAT_EMAIL'], 1)
    erb :'students/index'
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

    if @user.non_student?
      flash.error = "#{@user} is not a student."
      redirect '/'
    end

    StatHat::API.ez_post_value("Students : Progress", ENV['STATHAT_EMAIL'], 1)

    if @user == @current_user
      @drafts = @user.posts.drafts
    end

    @posts = Post.published.paginate(page: 1, user: @user)
    erb :'students/progress_index'
  end

  get '/:netid/progress/page/:page_number/?' do
    authenticate
    @user = User.first netid: params[:netid]

    halt 404 if @user.nil?

    StatHat::API.ez_post_value("Students : Progress", ENV['STATHAT_EMAIL'], 1)

    @posts = Post.published.paginate(page: params[:page_number], user: @user)
    erb :'students/progress_index'
  end

  get '/:netid/progress/:category?' do
    authenticate
    @user = User.first netid: params[:netid]
    @category = Category.first slug: params[:category]

    # Stop here if no user was found with a matching netid.
    halt 404 if @user.nil?

    StatHat::API.ez_post_value("Students : Progress : Category", ENV['STATHAT_EMAIL'], 1)

    @posts = Post.published.paginate(page: 1, user: @user, category_id: @category.id)

    erb :'students/progress_index'
  end

  get '/:netid/progress/:category/page/:page_number/?' do
    authenticate
    @user = User.first netid: params[:netid]

    # Stop here if no user was found with a matching netid.
    halt 404 if @user.nil?

    @category = Category.first slug: params[:category]

    StatHat::API.ez_post_value("Students : Progress : Category", ENV['STATHAT_EMAIL'], 1)

    @posts = Post.published.paginate(page: params[:page_number], user: @user, category_id: @category.id)

    erb :'students/progress_index'
  end

  #############################################################################
  #
  # THESIS PAGE
  #
  #############################################################################

  get '/:netid/thesis/?' do
    redirect "/students/#{params[:netid]}"
  end

  get '/:netid/thesis/edit' do
    authenticate

    unless (env['warden'].user.netid == params[:netid] || env['warden'].user.advisor?)
      flash.error = "That page belongs to #{params[:netid]}"
      redirect request.referrer
    end

    @tags = Tag.all(order: :name.asc)
    @site_config = SiteConfig.first
    if @site_config.thesis_lock && !env['warden'].user.advisor?
      flash.error = "Edits to thesis summaries are currently locked for review."
      redirect "/students/#{params[:netid]}/thesis"
    end

    @user = User.first(netid: params[:netid])

    @thesis = @user.theses.last
    erb :'students/thesis_edit'
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

    @user.public_thesis = params[:user][:public_thesis]

    old_thesis = @user.theses.last
    params[:thesis][:id] = nil
    params[:thesis][:created_at] = nil
    new_thesis = Thesis.new(old_thesis.attributes.merge(params[:thesis]))

    new_thesis.tags = Tag.all(id: params[:tags])

    if params[:image]
      image_path = "#{@user.netid}-#{Time.now.to_i}/#{URI.escape(params[:image][:filename].gsub(" ","_"))}"

      AWS::S3::Base.establish_connection!(:access_key_id => ENV['S3_ACCESS_KEY'], :secret_access_key => ENV['S3_SECRET_KEY'])
      AWS::S3::S3Object.store(image_path, open(params[:image][:tempfile]), "itp-thesis", access: :public_read)
       new_thesis.image = "http://itp-thesis.s3.amazonaws.com/" + image_path
    end

    @user.theses << new_thesis

    if @user.save
      flash.success = "Thesis summary."
      redirect "#{@user.url}"
    else
      flash.error = "There was an error updating your thesis."
      redirect "#{@user.url}/thesis/edit"
    end
  end

  get '/:netid/thesis/history' do
    @user = User.first(netid: params[:netid])
    @current_user = env['warden'].user
    authenticate unless @user.public_thesis

    halt 404 if @user.nil?

    if @user.non_student?
      flash.error = "#{@user} does not have a thesis in the system."
      redirect '/'
    end

    @theses = @user.theses

    erb :'students/thesis_history'
  end

  #############################################################################
  #
  # COMMENTS
  #
  #############################################################################

  get '/:netid/comments/?' do
    authenticate
    @user = User.first(netid:params[:netid])

    halt 404 if @user.nil?

    @comments_by = Comment.all(user: @user, order: :created_at.desc)
    @comments_to = @user.posts.comments.all(order: :created_at.desc)
    erb :'students/comments'
  end

  #############################################################################
  #
  # POSTS
  #
  #############################################################################

  get '/:netid/:id/:slug/?' do
    @current_user = env['warden'].user

    # Get the post with only the necessary fields.
    @post = Post.first(id: params[:id], active: true)

    # Redirect if the post is a draft
    if @post.nil? || (@current_user.nil? && !@post.is_public) || (@post.draft && @post.user_id != @current_user.id )
      flash.error = "Sorry, that post is not viewable."
      redirect "/"
    elsif !@post.is_public && !env['warden'].authenticated?
      env['warden'].authenticate!
    else
      StatHat::API.ez_post_value("Students : Progress : Post", ENV['STATHAT_EMAIL'], 1)
      @current_user = env['warden'].user
      erb :'students/progress_show'
    end
  end

  get '/:netid/:id/:slug/edit/?' do
    check_user(params[:netid])
    redirect "/posts/#{params[:id]}/edit"
  end

  get '/:netid/:id/:slug/delete' do
    authenticate
    check_user(params[:netid])

    Post.first(id: params[:id]).delete

    redirect "/students/#{params[:netid]}/progress"
  end

  get '/new' do
    redirect '/posts/new'
  end

  #############################################################################
  #
  # PROFILE PAGE
  #
  #############################################################################

  get '/:netid/?' do
    @user = User.first(netid: params[:netid])
    @current_user = env['warden'].user
    authenticate unless @user.public_thesis

    halt 404 if @user.nil?

    if @user.non_student?
      flash.error = "#{@user} does not have a thesis in the system."
      redirect '/'
    end

    StatHat::API.ez_post_value("Students : Thesis", ENV['STATHAT_EMAIL'], 1)

    @thesis = @user.theses.last

    if @current_user && @current_user.non_student?
      @feedback = @user.received_feedbacks.all(active: true)
    end

    erb :'students/thesis'
  end
end