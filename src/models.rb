DataMapper.setup(:default,
  ENV['DATABASE_URL'] || "postgres://localhost/thesisprog")

class Post
  include DataMapper::Resource

  property :id, Serial, key: true
  property :title, String
  property :content, Text
  property :private, Boolean

  property :created_at, DateTime
  property :updated_at, DateTime

  property :category_id, Integer, required: false
  property :assignment_id, Integer, required: false

  belongs_to :category
  belongs_to :assignment

  def published
    created_at.strftime("%B %e, %Y")
  end

  def url
    time = created_at.strftime("%Y/%m/%d")
    "/progress/#{time}/#{title}"
  end

  self.per_page = 10
end

class Category
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :year, Integer

  has n, :posts

  def to_s
    name
  end
end

class Section
  include DataMapper::Resource

  property :id, Serial
  property :name, String
end

class Assignment
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :content, Text

  property :due_at, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :posts
end

class User
  include DataMapper::Resource

  property :id, Serial
  property :netid, String
  property :password, String
  property :year, Integer
  property :role, String

  def self.authenticate(netid, password)
    user = self.first(netid: netid)
    user if user && user.password == password
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!

User.create(netid: 'ab1234', password: 'thesis', year: 2012)