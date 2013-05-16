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

  post '/tags/?' do
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

  ####################################################
  #
  #  THESIS REVIEWS
  #
  ####################################################
  post '/reviews/?' do
    require_non_student
    json = JSON.parse(request.body.read)

    @review = Review.new(json)
    @review.reviewer_id = @current_user.id

    if @review.save
      @review.to_json
    else
      halt 500
    end
  end

  get '/reviews/:id' do
    require_non_student
    @review = Review.get(params[:id])

    halt 404 if @review.nil?

    @review.to_json
  end

  put '/reviews/:id' do
    require_non_student
    json = JSON.parse(request.body.read)

    @review = Review.get(params[:id])

    halt 404 if @review.nil?

    @review.update(json)
    @review.to_json
  end

  get '/thesisweek/schedule' do
    @presentations = Presentation.all order: :presentation_time.asc

    response = []

    @presentations.each do |p|
      temp = p.attributes
      temp[:presentation_time] = p.presentation_time.to_i
      temp[:student] = p.user.to_s
      temp[:thesis] = p.user.thesis.title
      temp[:advisor] = p.user.students_advisor.to_s
      temp[:date] = p.presentation_time.day
      temp[:weekday] = p.presentation_time.wday
      temp[:time] = "#{p.presentation_time.hour}:#{p.presentation_time.minute}"
      response << temp
    end
    response.to_json
  end

  get '/student_list' do
    content_type :html
    @students = User.all(order: :first_name, role: "student")
    output = ""
    @students.each do |student|
      output += "<p>#{student.to_s}</p>"
    end
    output
  end
end