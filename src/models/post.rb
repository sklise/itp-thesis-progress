class Post
  include DataMapper::Resource

  property :id, Serial, key: true
  property :created_at, DateTime
  property :updated_at, DateTime
  property :published_at, DateTime

  property :title, String
  property :content, Text
  property :private, Boolean

  property :user_id, Integer, required: true
  property :category_id, Integer, required: false
  property :assignment_id, Integer, required: false

  belongs_to :category
  belongs_to :assignment
  belongs_to :user

  self.per_page = 10

  def published
    created_at.strftime("%B %e, %Y")
  end

  def url
    time = created_at.strftime("%Y/%m/%d")
    "/progress/#{time}/#{title}"
  end
end