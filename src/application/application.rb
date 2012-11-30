class ApplicationApp < Sinatra::Base
  set :views, Proc.new { File.join(root, "views") }
  set :erb, layout: :'../../views/layout'


  post '/submit' do
    @user = User.first(netid: params[:netid])

    @application = @user.application || Application.new

    @application.description          = params[:description]
    @application.write_in             = params[:write_in_label]
    @application.strengths            = params[:strengths]
    @application.help                 = params[:help]
    @application.url                  = params[:url]
    @application.labels               = params[:labels]
    @application.preferred_classmates = params[:preferred_classmates]

    @user.application = @application

    if @user.save
      "success!"
    else
      "uhoh, go find Steve!"
    end
  end
end