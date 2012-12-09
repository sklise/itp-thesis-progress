class Section
  include DataMapper::Resource

  before :save, :ensure_slug

  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime

  property :name, String
  property :year, Integer, default: Date.today.year
  property :slug, Slug

  def ensure_slug
    if self.slug.nil?
      self.slug = name.lowercase
    end
  end

  def path
    "/#{year}/#{slug}"
  end

  def students
    users.all(:role => "student")
  end

  def advisor
    users.first(:role => "advisor")
  end

  has n, :assignments, through: Resource
  has n, :users, through: Resource
end