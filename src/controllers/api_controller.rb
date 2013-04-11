class API < Sinatra::Base
  register Sinatra::ThesisApp
  register WillPaginate::Sinatra

  before do
    env['warden'].authenticate!
    @current_user = env['warden'].user
    content_type :json
  end

  #################################################
  #                                               #
  # TAGS API                                      #
  #                                               #
  #################################################

  get '/tags/?' do
    @tags = Tag.all(order: :name.asc)
    @tags.to_json
  end

  post '/tags' do
    require_admin
    json = JSON.parse(request.body.read)

    @tag = Tag.new(json)

    if @tag.save
      @tag.to_json
    else
      halt 500
    end
  end

  get '/tags/:id' do
    @tag = Tag.get(params[:id])

    @tag.to_json
  end

  put '/tags/:id' do
    require_admin
    json = JSON.parse(request.body.read)

    @tag = Tag.get(params[:id])

    halt 404 if @tag.nil?

    @tag.update(json)
    @tag.to_json
  end

  delete '/tags/:id' do
    require_admin

    @tag = Tag.get(params[:id])

    halt 404 if @tag.nil?

    @tag.destroy
    {success: 'ok'}.to_json
  end

  #################################################
  #                                               #
  #          POSTS                                #
  #                                               #
  #################################################

  post '/posts/?' do
    post_params = JSON.parse(request.body.read)

    post_params['user_id'] = env['warden'].user.id

    @post = Post.new(post_params)

    if @post.save
      @post.to_json
    else
      halt 500
    end
  end

  put '/posts/:id' do
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