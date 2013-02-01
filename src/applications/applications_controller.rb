class ApplicationApp < Sinatra::Base
  set :logging, true
  set :cache, Dalli::Client.new
  set :enable_cache, true
  set :views, Proc.new { File.join(root, "views") }
  set :erb, layout: :'../../views/layout'

  before do
    env['warden'].authenticate!
    require_non_student
  end

  get '/' do
    cache_control :public, max_age: 3600  # 30 mins.
    @users = User.all(year: 2013, order: :first_name)
    @applications = Application.all
    @no_application = @users.has_application(false)
    @submitted = @users.has_application
    erb :list
  end

  get '/printout' do
    @users = User.all(year: 2013, order: :first_name)
    @applications = Application.all
    erb :print_all
  end

  # post '/submit' do
  #   @user = User.first(netid: params[:netid])

  #   if @user.nil?
  #     # Silently fail when a netid is submitted that is not already in the
  #     # database.
  #     @user = User.new(netid: params[:netid])
  #   end

  #   @application = @user.application || Application.new
  #   @application.save_from_form(params, @user)
  #   @user.application = @application

  #   if @user.save
  #     flash.success = "Congratulations, your thesis application has been submitted. Enjoy the rest of your Saturday."
  #   else
  #     puts DateTime.now.to_s + "  >>>>  #{@application.inspect} //// #{@user.inspect}"
  #     flash.error = "There was an error saving your application. Please be sure you have filled out all fields properly and try again. If this problem persists, please contact Steve either in the Residents' Office or by email at sk3453@nyu.edu."
  #   end

  #   erb :submit, layout: :'layout'
  # end

  get '/:netid' do
    @user = User.first netid: params[:netid]

    if @user.nil?
      flash.error "The user you requested does not exist."
      redirect '/applications/?'
    end

    @mentioned_by = Application.all(:preferred_classmates.like => "%"+@user.netid+"%").user
    @mentioned = User.all(netid: @user.application.requested)

    erb :show
  end
end

class ApplicationSubmit < Sinatra::Base
  get '/' do
    'hi'
  end

  post '/' do
    @user = User.first(netid: params[:netid])

    if @user.nil?
      # Silently fail when a netid is submitted that is not already in the
      # database.
      @user = User.new(netid: params[:netid])
    end

    @application = @user.application || Application.new
    @application.save_from_form(params, @user)
    @user.application = @application

    if @user.save
      flash.success = "Congratulations, your thesis application has been submitted. Enjoy the rest of your Saturday."
    else
      puts DateTime.now.to_s + "  >>>>  #{@application.inspect} //// #{@user.inspect}"
      flash.error = "There was an error saving your application. Please be sure you have filled out all fields properly and try again. If this problem persists, please contact Steve either in the Residents' Office or by email at sk3453@nyu.edu."
    end

    erb :submit, layout: :'layout'
  end
end