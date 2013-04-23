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
    @students = User.students.all(year: 2013, order: :preferred_last.asc)
    @theses = []

    @students.each do |student|
      @theses << student.theses.last
    end

    csv_string = CSV.generate do |csv|
      csv << ["Name", "Title", "Elevator", "Description", "PhotoURL", "URL", "TAGS", "@imagepath", "@tag1", "@tag2", "@tag3", "@tag4"]

      @theses.each do |thesis|
        image = thesis.user.book_image_url ? thesis.user.book_image_url : thesis.image

        tags = thesis.tags.map{|x| x.name.gsub(/[\/ ]/,"_")}

        csv << [
          "#{thesis.user}",
          "#{thesis.title}",
          "#{thesis.elevator_pitch.gsub(/\r\n/, '<OYEZ>')}",
          "#{thesis.description.gsub(/\r\n/, '<OYEZ>')}",
          "http://itp-thesis.s3.amazonaws.com/2013/#{thesis.user.netid}.pdf",
          "http://thesis.itp.io/#{thesis.user.netid}",
          "#{thesis.tags.map{|x| x.name}.join(";")}",
          "Dropbox:ITP_THESIS_BOOK:book_images:#{thesis.user.netid}.pdf",
          "Dropbox:ITP_THESIS_BOOK:tags:#{tags[0] || "notag"}.pdf",
          "Dropbox:ITP_THESIS_BOOK:tags:#{tags[1] || "notag"}.pdf",
          "Dropbox:ITP_THESIS_BOOK:tags:#{tags[2] || "notag"}.pdf",
          "Dropbox:ITP_THESIS_BOOK:tags:#{tags[3] || "notag"}.pdf",
        ]
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