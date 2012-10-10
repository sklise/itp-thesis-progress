class ProgressApp < Sinatra::Base
  set :views, Proc.new { File.join(root, "views/progress") }

  get '/new' do
    erb :new_post, :layout => :"/../layout"
  end

  get '/save' do
    raise params.inspect
  end


end