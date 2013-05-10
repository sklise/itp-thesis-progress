class Presentation
  include DataMapper::Resource

  property :id, Serial
  property :user_id, Integer
  property :presentation_time, DateTime

  belongs_to :user

  def self.quick(netid, day_of_may, time)
    p = Presentation.new
    p.user = User.first :netid => netid
    p.presentation_time = DateTime.parse("2013/05/" + day_of_may.to_s + " " + time)
    p.save
  end
end