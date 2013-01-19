class Assignment
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime

  property :title, String
  property :brief, Text

  property :due_at, DateTime

  has n, :posts
  has n, :sections, through: Resource

  def year
    created_at.year
  end

end