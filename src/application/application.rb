class ApplicationApp < Sinatra::Base
  set :views, Proc.new { File.join(root, "views") }
  set :erb, layout: :'../../views/layout'

  require 'json'

  post '/submit' do
    @user = User.first(netid: params[:netid])

    if @user.nil?
      # CRAP!
      @user = User.new
    end

    @application = @user.application || Application.new

    raise params.inspect

    @application.description          = params[:description]
    @application.write_in             = params[:write_in_label]
    @application.strengths            = params[:strengths]
    @application.help                 = params[:help]
    @application.url                  = params[:url]
    @application.labels               = params[:labels].join(",")
    @application.preferred_classmates = params[:preferred_classmates].join(",")
    @application.user_id = @user.id

    @user.application = @application

    if @user.save
      "success!"
    else
      "There was an error. Please contact Steve for help."
    end
  end
end