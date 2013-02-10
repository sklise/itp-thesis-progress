class Section
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime

  property :name, String
  property :year, Integer, default: Date.today.year
  property :slug, Slug

  def path
    "/sections/#{year}/#{slug}"
  end

  def students
    users.all role: "student"
  end

  def advisor
    users.first role: "advisor"
  end

  def resident
    users.first role: "resident"
  end

  has n, :assignments, through: Resource
  has n, :announcements, through: Resource
  has n, :users, through: Resource

  before :save do |section|
    if section.slug.nil? || section.slug.length == 0
      section.slug = section.name.downcase
    end
  end

  def url
    "/sections/#{self.year}/#{self.slug}"
  end

  def remove_users
    self.users = []
    puts self.users
    self.save
  end
end