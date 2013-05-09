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
    require_non_student

    @reviews = Review.all(:reviewer_id => @current_user.id)

    @sections = Section.all
    erb :'admin/reviews'
  end
end