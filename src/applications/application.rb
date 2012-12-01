class ApplicationApp < Sinatra::Base
  set :views, Proc.new { File.join(root, "views") }

  post '/submit' do
    @user = User.first(netid: params[:netid])

    if @user.nil?
      # CRAP!
      @user = User.new(netid: params[:netid])
    end

    @application = @user.application || Application.new

    @application.description          = params[:description] || ""
    @application.write_in             = params[:write_in_label] || ""
    @application.strengths            = params[:strengths]|| ""
    @application.help                 = params[:help]|| ""
    @application.url                  = params[:url] || ""
    @application.labels               = (params[:labels] || [""]).join(",")
    @application.preferred_classmates = (params[:preferred_classmates] || [""]).join(",")
    @application.user_id = @user.id

    @user.application = @application

    if @user.save
      flash.success = "Congratulations, your thesis application has been submitted. Enjoy the rest of your Saturday."
    else
      puts DateTime.now.to_s + "  >>>>  #{@application.inspect} //// #{@user.inspect}"
      flash.error = "There was an error saving your application. Please be sure you have filled out all fields properly and try again. If this problem persists, please contact Steve either in the Residents' Office or by email at sk3453@nyu.edu."
    end

    erb :submit
  end
end