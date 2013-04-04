require 'csv'

class BookMaker < Sinatra::Base
  register Sinatra::ThesisApp

  before do
    env['warden'].authenticate!
    @current_user = env['warden'].user
  end

  get '/' do
    @d = Date.today
    redirect "/book/thesisbook-#{@d.year}-#{@d.month}-#{@d.day}.csv"
  end

  get '/thesisbook-:year-:month-:day.csv' do
    content_type :text
    @students = User.students.all(year: 2013, order: :last_name.asc)
    @theses = []

    @students.each do |student|
      @theses << student.theses.last
    end

    csv_string = CSV.generate do |csv|
      csv << ["Name", "Title", "Elevator", "Description", "PhotoURL", "URL"]

      @theses.each do |thesis|
        csv << ["#{thesis.user}", "#{thesis.title}", "#{thesis.elevator_pitch}", "#{thesis.description}", "#{thesis.image}", "http://thesis.itp.io/students/#{thesis.user.netid}"]
      end
    end

    csv_string
  end

end