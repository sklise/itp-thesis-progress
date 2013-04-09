class Tag
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime
  property :modified_at, DateTime

  property :name, String, length: 64

  has n, :theses, through: Resource
end