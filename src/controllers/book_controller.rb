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
      csv << ["Name", "Title", "Elevator", "Description", "PhotoURL", "URL", "TAGS", "IMAGE URL"]

      @theses.each do |thesis|
        image = thesis.user.book_image_url ? thesis.user.book_image_url : thesis.image

        csv << ["#{thesis.user}", "#{thesis.title}", "#{thesis.elevator_pitch}", "#{thesis.description}", "#{image}", "http://thesis.itp.io/students/#{thesis.user.netid}", "#{thesis.tags.map{|x| x.name}.join(";")}", "http://itp-thesis.s3.amazonaws.com/#{thesis.user.netid}/book_image.pdf"]
      end
    end

    csv_string
  end

  get '/:netid' do
    @user = User.first netid: params[:netid]
    halt 404 if @user.nil? || !@user.student?

    @posts = @user.posts.published.reverse
    @theses = @user.theses
    @thesis = @theses.last

    erb :'book/student', layout: :'book/layout'
  end

end