class AdminApp < Sinatra::Base
  register Sinatra::ThesisApp

  before do
    env['warden'].authenticate!
    @current_user = env['warden'].user
  end

  get '/' do
    if @current_user.admin?
      @site_config = SiteConfig.first

      @tags = Tag.all(fields: [:name, :id])
      @tag_hash = {}

      @tags.each do |tag|
        @tag_hash[tag.name] = {name: tag.name, count: 0}
      end

      @theses = []

      User.students.each do |student|
        @theses << student.thesis
      end

      @theses.each do |thesis|
        thesis.tags.each do |tag|
          @tag_hash[tag.name][:count] += 1
        end
      end

      @tag_array = []
      @tag_hash.each do |k,v|
        @tag_array << v
      end

      erb :'admin/config'
    else
      erb :'admin/profile'
    end

  end

  post '/' do
    if @current_user.admin?
      @site_config = SiteConfig.first

      if params[:thesis_lock].nil?
        params[:thesis_lock] = false
      end

      @site_config.update(params)
    else
      @user = User.get @current_user.id

      @user.preferred_first = params[:preferred_first]
      @user.preferred_last = params[:preferred_last]

      @user.save
    end

    redirect '/admin'
  end

  get '/reviews' do
    require_adult

    @reviews = Review.all(:reviewer_id => @current_user.id)

    @sections = Section.current_year
    erb :'admin/reviews'
  end

  get '/reviews/students' do
    require_adult

    @students = User.all(
      :role => "student",
      :order => :first_name,
      :year => ENV['CURRENT_YEAR'])

    erb :'admin/reviews_index'
  end

  get '/reviews/:netid' do
    require_adult
    @students = User.all(
      :role => "student",
      :order => :first_name,
      :year => ENV['CURRENT_YEAR'])
    @student = User.first(:netid => params[:netid])
    @reviews = Review.all(:student_id => @student.id)
    erb :'admin/reviews_show'
  end

  get '/users/add' do
    require_non_student
    erb :'admin/add_users'
  end

  post '/users' do
    require_non_student

    users = params[:users].split("\r\n").map({|m| m.split(",")})
    users.each do |user|
      if user.length == 3
      @user = User.first_or_create(:netid => user[2])
      @user.update(
        :first_name => users[0],
        :last_name => users[1],
        :role => params[:role]
      )
      "ok"
    end

  end
end