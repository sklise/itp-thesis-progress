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

  belongs_to :category

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

  has n, :posts

  def to_s
    name
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!