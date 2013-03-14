class PostsApp < Sinatra::Base
  set :views, Proc.new { File.join(File.dirname(__FILE__), "views") }
  set :erb, layout: :"../../views/layout"

  before do
    env['warden'].authenticate!
    @current_user = env['warden'].user
  end

  get '/new' do
    @section = env['warden'].user.sections.first
    @assignments = @section.assignments
    @assignment = Assignment.get(params[:assignment_id])
    @categories = Category.all
    @post = Post.new
    erb :compose
  end

  get '/:id/edit' do
    @section = env['warden'].user.sections.first
    @assignments = @section.assignments
    @assignment = Assignment.get(params[:assignment_id])
    @categories = Category.all
    @post = Post.active.get(params[:id])
    check_user(@post.user.netid)

    if @post.nil?
      flash.error = "Sorry, the post you were trying to edit does not exist"
      redirect "/"
    end

    erb :compose
  end

  post '/' do
    content_type :json
    post_params = JSON.parse(request.body.read)

    post_params['user_id'] = env['warden'].user.id

    @post = Post.new(post_params)

    if @post.save
      @post.to_json
    else
      halt 500
    end
  end

  put '/:id' do
    content_type :json
    post_params = JSON.parse(request.body.read)

    @post = Post.get(params[:id])
    check_user(@post.user.netid)

    @post.update({
      title: post_params['title'],
      is_public: post_params['is_public'],
      content: post_params['content'],
      draft: post_params['draft'],
      category_id: post_params['category_id'],
      assignment_id: post_params['assignment_id']
    })

    @post.to_json
  end
end