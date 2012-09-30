require './models'
require './helpers'

class Thesis < Sinatra::Base

  get '/' do

  end

  # If you're a teacher, links to your sections and a "blog feed" of recent
  # posts by your students.
  get '/dashboard' do

  end

  get '/students/:name' do

  end

  # Big 'ol list of everyone from that year and links to the sections
  get '/years/:year' do

  end

  # Year listed by section
  get '/years/:year/sections' do

  end

  # An individual section
  get '/years/:year/sections/:section' do

  end
end