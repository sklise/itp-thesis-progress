# This is the app for students to edit and view their thesis

class ThesisApp < Sinatra::Base
  set :views, Proc.new { File.join(root, "views") }
  set :erb, layout: :'../../views/layout'

  before do
    env['warden'].authenticate!
  end

  get '/?' do
    @thesis = Thesis.first(:user => env['warden'].user)
    erb :thesis
  end

  get '/edit' do
    @thesis = Thesis.first(:user => env['warden'].user)
    erb :edit
  end

  post '/update' do
    content_type :json
    @thesis = Thesis.first(:user => env['warden'].user)

    # Notify advisor!

    if @thesis.update(params[:thesis])
      flash.success = "Thesis updated, please tell your advisor."
      redirect '/thesis'
    else
      flash.error = "There was an error updating your thesis."
      redirect '/thesis/edit'
    end
  end
end