class ApplicationApp < Sinatra::Base
  set :views, Proc.new { File.join(root, "views") }
  set :erb, layout: :'../../views/layout'


  post '/submit' do
    raise params.inspect
  end
end