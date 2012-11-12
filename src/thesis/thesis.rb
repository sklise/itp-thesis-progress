# This is the app for students to edit and view their thesis

class ThesisApp < Sinatra::Base
  set :views, Proc.new { File.join(root, "views") }
  set :erb, layout: :'../../views/layout'

  before do
    env['warden'].authenticate!
  end

  get '/' do
    @thesis = Thesis.first(:user => env['warden'].user)
    erb :thesis
  end

  post '/update' do

  end
end